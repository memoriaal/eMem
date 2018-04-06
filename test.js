const path = require('path')
const util = require('util')
const async = require('async')
const fs = require('fs')

var first_line_is_for_labels = true

const ES_CREDENTIALS = process.env.ES_CREDENTIALS
const INDEX = process.env.INDEX
const SOURCE = process.env.SOURCE
const QUEUE_LENGTH = 1
const BULK_SIZE = 2
// const BULK_SIZE = 4100
const START_TIME = Date.now()


const elasticsearch = require('elasticsearch')
const esClient = new elasticsearch.Client({
  host: 'https://' + ES_CREDENTIALS + '@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243',
  // log: 'trace'
})

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
  count: function(callback) {
    esClient.count({index: INDEX},function(err,resp,status) {
      callback(null, resp);
    })
  }
}, function(err, results) {
  console.log(results)
})

console.log('finito 1')
