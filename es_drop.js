const util = require('util')
const ES_CREDENTIALS = process.env.ES_CREDENTIALS
const INDEX = process.env.INDEX

const elasticsearch = require('elasticsearch')
const esClient = new elasticsearch.Client({
  host: 'https://' + process.env.ES_CREDENTIALS + '@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243',
  // log: 'trace'
})
esClient.indices.delete(
  {index: INDEX}, 
  (err, response) => {
    console.log(require('util').inspect(err, { depth: null }))
    console.log(require('util').inspect(response, { depth: null }))
  }
)
