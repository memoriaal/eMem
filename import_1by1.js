const path = require('path')
const util = require('util')
const async = require('async')
const fs = require('fs')

var first_line_is_for_labels = true

const ES_CREDENTIALS = process.env.ES_CREDENTIALS
const INDEX = process.env.INDEX
const SOURCE = process.env.SOURCE
const QUEUE_LENGTH = 2
// const BULK_SIZE = 507
const BULK_SIZE = 2100
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
  let ksplit = kirje.split('#|')
  if (ksplit.length != 6) {
    console.log('---\n' + kirje)
  }
  o_kirje.persoon = ksplit.shift()
  o_kirje.kirjekood = ksplit.shift()
  o_kirje.RaamatuPere = o_kirje.kirjekood.slice(0,-2)
  o_kirje.kirje = ksplit.shift()
  o_kirje.words = o_kirje.kirje.split(' ').slice(0,3).join(' ').replace(/[.,;]/g,'')
  // o_kirje.allikakood = o_kirje.kirjekood.split('-')[0]
  o_kirje.allikas = ksplit.shift()
  o_kirje.allikasTxt = ksplit.shift()
  _labels_str = ksplit.shift().split("'").join('"')
  // console.log(o_kirje.kirjekood, _labels_str);
  _labels_o = JSON.parse(_labels_str)
  // console.log(_labels_o);
  if (_labels_o[0] === '') {
    _labels_o = []
  }
  o_kirje.labels = _labels_o['labels'].join(' ')
  return o_kirje
}

const nimekiri_o = {
  EMI:  'Represseeritute nimestik',
  EVO:  'Kommunistliku terrori läbi hukkunud Eesti ohvitserid',
  JWMR: 'Kommunismiohvritest Eesti juutide andmebaas',
  KIVI: 'Kommunismiohvrite Memoriaalile kantavate isikute nimestik',
  LMSS: 'Herbert Lindmäe, Suvesõda 1941',
  MM:   'Hukkunud metsavendade nimestik',
  PR:   'Pereregistri andmebaas',
  R1:   'Poliitilised arreteerimised Eestis 1940–1988',
  R2:   'Poliitilised arreteerimised Eestis',
  R3:   'Poliitilised arreteerimised Eestis',
  R41:  'Märtsiküüditamine 1949',
  R42:  'Märtsiküüditamine 1949',
  R5:   'Märtsiküüditamine 1949',
  R61:  'Küüditatud 1940',
  R62:  'Küüditatud juunis & juulis 1941',
  R63:  'Sakslastena küüditatud 15.08.1945',
  R64:  'Vahepealsetel aegadel küüditatud 1945-1953',
  R65:  'Küüditatud usutunnistuse pärast',
  R81:  'Represseeritute lisanimestik 1940-1990 (R8/1)',
  R82:  'Lisanimestik 1940-1990 (R8/2)',
  R83:  'Eestist 1945-1953 küüditatute nimekiri (R8/3)',
  RK:   'Poliitilistel põhjustel süüdimõistetud',
  RR:   'Rahvastikuregister',
  SJV:  'Nõukogude sõjavangi- ja filterlaagrites hukkunud eestlased',
  TS:   'Tagasiside veebist memoriaal.ee',
}

console.log('start 0')


async.series({
  delete: function(callback) {
    console.log('Deleting ' + INDEX);
    esClient.indices.delete(
      {index: INDEX},
      function(err,resp,status) {
        console.log("deleted", resp)
        callback(null, resp)
      }
    )
  },
  create: function(callback) {
    console.log('Creating ' + INDEX);
    esClient.indices.create(
      { index: INDEX },
      function(err,resp,status) {
        if(err) {
          console.log(err);
          callback(err)
        }
        else {
          console.log('created', resp);
          callback(null, resp)
        }
      }
    )
  },
  mapping: function(callback) {
    console.log('Mapping the limits')
    callback(null)
  },
  reading: function(callback) {
    console.log('Reading ' + SOURCE);
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
        if (isik.id === '') {
          return
        }
        isik['kirjed'] = isik['kirjed'].split(';_\n')
        .filter((kirje) => kirje !== '')
        .map((kirje) => {
          return kirje2obj(kirje)
        })
        let pereseosed = isik['pereseos'].split(';_\n')
        .filter((kirje) => kirje !== '')
        .map((kirje) => {
          return kirje2obj(kirje)
        })
        let pered = {}
        pereseosed.forEach((kirje) => {
          let RaamatuPere = kirje.kirjekood.slice(0,-2)
          if (pered[RaamatuPere] === undefined) {
            let nimekiri = nimekiri_o[RaamatuPere.split('-')[0]] || '#N/A'
            pered[RaamatuPere] = {
              RaamatuPere: RaamatuPere,
              nimekiri: nimekiri,
              kirjed: []
            }
          }
          pered[RaamatuPere]['kirjed'].push(kirje)
        })
        isik['pereseos'] = Object.values(pered)
        // console.log('Saving ' + isik.id);


        save2db(isik, function(error) {
          if (error) {
            console.log(error)
            process.exit(1)
          } else {
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
let rec_no = 0

var q = queue(function(tasks, callback) {
  esClient.bulk({
    body: tasks
  }, function (error, response) {
    if (error) {
      console.log('Error ' + error.status)
      if (error.status === 408) {
        console.log('Timed out')
        q.push(tasks, callback)
        return // callback next time
      }
      console.log('E: ' + error.status)
      return callback(error)
    }
    let waitResults = () => {
      setTimeout(function () {
        esClient.count({index: INDEX},function(err,resp,status) {
          let cnt = resp.count
          rec_no += 1
          if (rec_no * BULK_SIZE === cnt) {
            // process.exit(1)
            console.log((rec_no * BULK_SIZE) + ' inserted, speed: ' + Math.floor((rec_no * BULK_SIZE)/(Date.now()-START_TIME)*1000) + '/sec')
            return callback(null)
          }
          else {
            console.log(rec_no * BULK_SIZE + '!==' + cnt)
            // console.log('Response: ', JSON.stringify(response));
            // rec_no -= 1
            return callback(null)
            // waitResults()
          }
        })
      }, 1000);
    }
    waitResults()
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
      body: bulk.join(';_\n'),
      refresh: 'wait_for'
    }, function (error, response) {
      if (error) {
        return callback(error)
      }
      return callback(null)
    })
  }
}
