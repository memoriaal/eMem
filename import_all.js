const path = require('path')
const util = require('util')
const async = require('async')
const fs = require('fs')

var first_line_is_for_labels = true

const ES_CREDENTIALS = process.env.ES_CREDENTIALS
const INDEX = process.env.INDEX
const SOURCE = process.env.SOURCE
const QUEUE_LENGTH = 1
const BULK_SIZE = 27
// const BULK_SIZE = 4100
const START_TIME = Date.now()





const convertLinks = function convertLinks(text) {
  var exp = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig;
  var text1 = text.replace(exp, "<a href='$1'>$1</a>");
  var exp2 =/(^|[^\/])(www\.[\S]+(\b|$))/gim;
  return text1.replace(exp2, '$1<a target="_blank" href="http://$2">$2</a>');
}

var csv = require("fast-csv");
var labels = []


const elasticsearch = require('elasticsearch')
const esClient = new elasticsearch.Client({
  host: 'https://' + ES_CREDENTIALS + '@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243',
  // log: 'trace'
})

const kirje2obj = function(kirje) {
  let o_kirje = {}
  ksplit = kirje.split('|')
  o_kirje.kirjekood = ksplit.shift()
  o_kirje.kirje = ksplit.join('|')
  return o_kirje
}

const nimekiri_o = {
  R5:  'Märtsiküüditamine 1949',
  R61: 'Küüditatud 1940',
  R62: 'Küüditatud juunis & juulis 1941',
  R63: 'Sakslastena küüditatud 15.08.1945',
  R64: 'Vahepealsetel aegadel küüditatud 1945-1953',
  R65: 'Küüditatud usutunnistuse pärast'
}

console.log('start 0')


async.series({
  // delete: function(callback) {
  //   esClient.indices.delete(
  //     {index: INDEX},
  //     function(err,resp,status) {
  //       console.log("delete", resp)
  //       callback(null, resp)
  //     }
  //   )
  // },
  // create: function(callback) {
  //   esClient.indices.create(
  //     {index: INDEX},
  //     function(err,resp,status) {
  //       if(err) {
  //         console.log(err);
  //         callback(err)
  //       }
  //       else {
  //         console.log("create", resp);
  //         callback(null, resp)
  //       }
  //     }
  //   )
  // },
  reading: function(callback) {
    csv
      .fromPath(SOURCE)
      .on("data", function(data) {
        if (first_line_is_for_labels) {
          first_line_is_for_labels = false
          labels = data
          return
        }
        let isik = {}
        // console.log(data);
        for (var i = 0; i < labels.length; i++) {
          // console.log('--> ', data[i]);
          if (data[i] !== undefined) {
            isik[labels[i]] = data[i].replace(/@/g, '"')
          }
        }
        isik['kirjed'] = isik['kirjed'].split('\n')
        .filter((kirje) => kirje !== '')
        .map((kirje) => {
          return kirje2obj(kirje)
        })
        let pereseosed = isik['pereseos'].split('\n')
        .filter((kirje) => kirje !== '')
        .map((kirje) => {
          return kirje2obj(kirje)
        })
        isik['pereseos'] = {}
        pereseosed.forEach((kirje) => {
          let perekood = kirje.kirjekood.slice(0,-2)
          if (isik.pereseos[perekood] === undefined) {
            let nimekiri = nimekiri_o[perekood.split('-')[0]] || '#N/A'
            isik.pereseos[perekood] = {
              perekood: perekood,
              nimekiri: nimekiri,
              kirjed: []
            }
          }
          isik.pereseos[perekood]['kirjed'].push(kirje)
        })

        save2db(isik, function(error) {
          if (error) {
            console.log(error)
            process.exit(1)
          } else {
            // console.log('created ', isik.id)
          }
        })
     } )
     .on("end", function(){
         console.log("done with reading");
         callback(null, "done with reading")
     });
  },
  count: function(callback) {
    esClient.count({index: INDEX},function(err,resp,status) {
      callback(null, resp);
    })
  }
}, function(err, results) {
  console.log(results)
})

console.log('finito 1')



const queue = require('async/queue')
let rec_no = 1
var q = queue(function(tasks, callback) {
  esClient.bulk({
    body: tasks
  }, function (error, response) {
    if (error) {
      if (error.status === 408) {
        console.log('Timed out')
        q.push(tasks, callback)
        return // callback next time
      }
      return callback(error)
    }
    console.log((rec_no * BULK_SIZE) + ' inserted, speed: ' + Math.floor((rec_no * BULK_SIZE)/(Date.now()-START_TIME)*1000) + '/sec')
    rec_no = rec_no + 1
    return callback(null)
  })
}, QUEUE_LENGTH)


q.drain = function() {

  save2db(false, function(error) {
    if (error) {
      console.log(error)
      process.exit(1)
    } else {
      console.log('all items have been processed 2')

      esClient.count({
        index: INDEX
      }, function (error, response) {
        var count = response.count
        console.log('Count: ' + count + ' speed: ' + Math.floor(count/(Date.now()-START_TIME)*1000) + '/sec')
        let create = {}
        create.index = 'imports'
        create.type = 'import'
        create.id = Date.now()
        create.body = {'INDEX': INDEX, 'records': count, 'ISODate': new Date().toISOString() }
        esClient.create(create, function(error, response) {
          if (error) {
            console.error(error)
            console.log(response)
          }
          console.log('bye')
        })
      })
    }
  })

  console.log('all items have been processed 1')
}

var bulk = []
const save2db = function save2db(isik, callback) {

  if (isik !== false) {
    bulk.push(JSON.stringify({'index':{'_index':INDEX,'_type':'isik','_id':isik.id}}))
    bulk.push(JSON.stringify(isik))
  }
  if (bulk.length/2 >= BULK_SIZE) {
    q.push(bulk.join('\n'), function(error) {
      if (error) {
        return callback(error)
      }
      return callback(null)
    })
    bulk = []
  }
  else if (isik === false && bulk.length > 0) {
    esClient.bulk({
      body: bulk.join('\n'),
      refresh: 'wait_for'
    }, function (error, response) {
      if (error) {
        return callback(error)
      }
      return callback(null)
    })
  }
}
