const path = require('path')
const util = require('util')
const async = require('async')
const fs = require('fs')

var first_line_is_for_labels = true

const ES_CREDENTIALS = process.env.ES_CREDENTIALS
const INDEX = process.env.INDEX
const SOURCE = process.env.SOURCE
const QUEUE_LENGTH = 10
const BULK_SIZE = 1000
const START_TIME = Date.now()

const allikalingid = {
  'r1':          { 'href':'http://www.memento.ee/memento_materjalid/memento_raamatud/memento_r_1.pdf',  'text':'Memento "POLIITILISED ARRETEERIMISED EESTIS 1940-1988' },
  'r2':          { 'href':'http://www.memento.ee/memento_materjalid/memento_raamatud/memento_r_2.pdf',  'text':'Memento "NÕUKOGUDE OKUPATSIOONIVÕIMU POLIITILISED ARRETEERIMISED EESTIS 1940-1988' },
  'r3':          { 'href':'http://www.memento.ee/memento_materjalid/memento_raamatud/memento_r_3.pdf',  'text':'Memento "NÕUKOGUDE OKUPATSIOONIVÕIMU POLIITILISED ARRETEERIMISED EESTIS 1940-1988' },
  'r4':          { 'href':'http://www.memento.ee/memento_materjalid/memento_raamatud/memento_r_4.pdf',  'text':'Memento "KÜÜDITAMINE EESTIST VENEMAALE MÄRTSIKÜÜDITAMINE 1949 1. osa' },
  'r5':          { 'href':'http://www.memento.ee/memento_materjalid/memento_raamatud/memento_r_5.pdf',  'text':'Memento "KÜÜDITAMINE EESTIST VENEMAALE MÄRTSIKÜÜDITAMINE 1949 2. osa' },
  'r6':          { 'href':'http://www.memento.ee/memento_materjalid/memento_raamatud/memento_r_6.pdf',  'text':'Memento "KÜÜDITAMINE  EESTIST VENEMAALE JUUNIKÜÜDITAMINE 1941 & KÜÜDITAMISED 1940-1953' },
  'r7':          { 'href':'http://www.memento.ee/memento_materjalid/memento_raamatud/memento_r_7.pdf',  'text':'Memento "NÕUKOGUDE OKUPATSIOONIVÕIMUDE KURITEOD EESTIS KÜÜDITATUD, ARRETEERITUD, TAPETUD 1940-1990 NIMEDE KOONDREGISTER R1 – R6' },
  'r81':         { 'href':'http://www.memento.ee/memento_materjalid/memento_raamatud/memento_r_81.pdf', 'text':'Memento "KOMMUNISMI KURITEOD EESTIS, Lisanimestik 1940–1990, raamatute R1–R7 täiendamiseks' },
  'r81_20':      { 'href':'http://www.memento.ee/memento_materjalid/memento_raamatud/memento_r_81.pdf', 'text':'Memento "KOMMUNISMI KURITEOD EESTIS, Lisanimestik 1940–1990, raamatute R1–R7 täiendamiseks' },
  'mnm':         { 'href':'www.arborit.eu/memento/kommunismiohvrite-memoriaal/Kommunismiohvrite%20memoriaali%20nime%20kirjed%20%2820-03-2017%29%20-%20Stat-Nimek.pdf', 'text':'Memento "KOMMUNISMIOHVRITE MEMORIAALI NIME KIRJETE STATISTIKA' },
  'okumus':      { 'href':'https://okupatsioon.entu.ee', 'text':'Okupatsioonide Muuseumi avalik vaade' },
  'metsavennad': { 'href':'', 'text':'Martin Andreller "Metsavendade nimekiri"' },
}

const convertLinks = function convertLinks(text) {
  var exp = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig;
  var text1 = text.replace(exp, "<a href='$1'>$1</a>");
  var exp2 =/(^|[^\/])(www\.[\S]+(\b|$))/gim;
  return text1.replace(exp2, '$1<a target="_blank" href="http://$2">$2</a>');
}

var csv = require("fast-csv");
var labels = []
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
      // console.log(data[i]);
      isik[labels[i]] = data[i].replace(/@/g, '"')
    }
    // console.log('go save', isik);
    isik.allikad = isik.allikad.split('\n').map(function(kirje) {
      let spl = kirje.split(':')
      let allikas = spl.shift()
      // console.log(allikas, allikalingid[allikas]);
      let txt = convertLinks(spl.join(':'))
      return {'allikas':allikalingid[allikas], 'kirje':txt}
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
 });


const elasticsearch = require('elasticsearch')
const esClient = new elasticsearch.Client({
  host: 'https://' + process.env.ES_CREDENTIALS + '@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243'
  // log: 'trace'
})

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
  else if (isik === false) {
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
