# add some fielddata mapping
curl -X PUT "https://elastic:XXX@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243/allpersons/_mapping/isik" -H 'Content-Type: application/json' -d'
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

curl -X POST "https://Delfi:B68-xvu-gds-HA8@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243/allpersons/_search?size=2&scroll=1m&pretty" -H 'Content-Type: application/json' -d' {
  "query": {
    "match": { "kivi": "1" }
  },
  "sort": [
    {"perenimi": "asc"},
    {"eesnimi": "asc"}
  ],
  "_source": [ "id", "perenimi", "eesnimi", "isanimi", "emanimi", "sünd", "surm" ],
}'

curl -X POST "https://Delfi:B68-xvu-gds-HA8@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243/_search/scroll?pretty" -H 'Content-Type: application/json' -d' {"scroll":"1m", "scroll_id":"DnF1ZXJ5VGhlbkZldGNoBQAAAAAABjbmFk1CZ2JjT2lUUzNDWTVOQmdwVFdWTmcAAAAAAAY25RZNQmdiY09pVFMzQ1k1TkJncFRXVk5nAAAAAAAGNugWTUJnYmNPaVRTM0NZNU5CZ3BUV1ZOZwAAAAAABjbnFk1CZ2JjT2lUUzNDWTVOQmdwVFdWTmcAAAAAAAY26RZNQmdiY09pVFMzQ1k1TkJncFRXVk5n"}'







# add some fielddata mapping
curl -X PUT "https://elastic:XXX@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243/allpersons/_mapping/isik" -H 'Content-Type: application/json' -d'
{
  "properties": {
    "eesnimi": {
      "type": "keyword"
    },
    "perenimi": {
      "type": "keyword"
    }
  }
}
'

curl -X POST "https://Delfi:B68-xvu-gds-HA8@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243/allpersons/_search?pretty" -H 'Content-Type: application/json' -d' {
  "query": {
    "multi_match": {
      "query": "valdas",
      "operator": "and",
      "fields": [ "perenimi", "eesnimi" ],
      "type": "cross_fields"
    }
  },
  "sort": [
    {"perenimi": "asc"},
    {"eesnimi": "asc"}
  ]
}'

curl -X POST "https://Delfi:B68-xvu-gds-HA8@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243/allpersons/_search?pretty" -H 'Content-Type: application/json' -d' {
  "query": {
    "multi_match": {
      "query": "valdas",
      "operator": "and",
      "fields": [ "perenimi", "eesnimi" ],
      "type": "cross_fields"
    }
  }
}'


curl -X POST "https://Delfi:B68-xvu-gds-HA8@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243/allpersons/_search?pretty" -H 'Content-Type: application/json' -d' {
  "query": {
    "match": { "kivi": "1" }
  },
  "sort": [
    {"perenimi": "asc"},
    {"eesnimi": "asc"}
  ],
  "_source": [ "id", "perenimi", "eesnimi", "isanimi", "emanimi", "sünd", "surm" ]
}'


curl -X POST "https://Delfi:B68-xvu-gds-HA8@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243/allpersons/_search?pretty" -H 'Content-Type: application/json' -d' {
  "query": {
    "multi_match": {
      "query": "valdas hans",
      "operator": "and",
      "fields": [ "_all" ],
      "type": "cross_fields"
    }
  },
  "sort": [
    {"perenimi": "asc"},
    {"eesnimi": "asc"}
  ],
  "_source": [ "id", "perenimi", "eesnimi", "isanimi", "emanimi", "sünd", "surm" ]
}'


# List all indices
curl -X GET "https://elastic:XXX@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243/_cat/indices?v"

# Delete index
curl -X DELETE "elastic:XXX@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243/personsall"
