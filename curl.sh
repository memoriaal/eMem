# add some fielddata mapping
curl -X PUT "https://elastic:xxxxxxx@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243/persons/_mapping/isik" -H 'Content-Type: application/json' -d'
{
  "properties": {
    "eesnimi": {
      "type":     "text",
      "fielddata": true
    },
    "perenimi": {
      "type":     "text",
      "fielddata": true
    }
  }
}
'

curl -X POST "https://Delfi:B68-xvu-gds-HA8@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243/persons/_search?size=2&scroll=1m&pretty" -H 'Content-Type: application/json' -d' {
  "query": {
    "match": { "kivi": "1" }
  },
  "sort": [
    {"eesnimi": "asc"}
  ]
}'

curl -X POST "https://Delfi:B68-xvu-gds-HA8@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243/_search/scroll?pretty" -H 'Content-Type: application/json' -d' {"scroll":"1m", "scroll_id":"DnF1ZXJ5VGhlbkZldGNoBQAAAAAABjbmFk1CZ2JjT2lUUzNDWTVOQmdwVFdWTmcAAAAAAAY25RZNQmdiY09pVFMzQ1k1TkJncFRXVk5nAAAAAAAGNugWTUJnYmNPaVRTM0NZNU5CZ3BUV1ZOZwAAAAAABjbnFk1CZ2JjT2lUUzNDWTVOQmdwVFdWTmcAAAAAAAY26RZNQmdiY09pVFMzQ1k1TkJncFRXVk5n"}'




curl -X POST "https://Delfi:B68-xvu-gds-HA8@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243/allpersons/_search?size=2&scroll=1m&pretty" -H 'Content-Type: application/json' -d' {
  "query": {
    "match": { "id": "0000073740" }
  }
}'
