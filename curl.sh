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




# List all indices
curl -X GET "https://Delfi:B68-xvu-gds-HA8@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243/_cat/indices?v"

# show indexes
curl -X GET "https://Delfi:B68-xvu-gds-HA8@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243/persons/_mapping/isik?pretty"

# Delete index
curl -X DELETE "elastic:XXXX@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243/personsall"




curl -X GET "https://Delfi:B68-xvu-gds-HA8@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243/persons/_search?pretty" -H 'Content-Type: application/json' -d'
{
    "query" : {
        "bool" : {
            "must" : {
                "multi_match" : {
                    "query": "mets",
                    "fields": [ "perenimi", "eesnimi", "perenimed", "eesnimed", "sünd", "surm", "id", "pereseosID" ],
                    "operator": "and",
                    "type": "cross_fields"
                }
            },
            "filter": { "term": { "kivi": "1" } }
        }
    },
    "sort": { "perenimi.raw": "asc", "eesnimi.raw": "asc" }
    ,
    "highlight": {
        "pre_tags": [ "<em>" ],
        "post_tags": [ "</em>" ],
        "fields": {
            "perenimi": {
                "number_of_fragments": 1,
                "fragment_size": 20
            },
            "eesnimi": {
                "number_of_fragments": 1,
                "fragment_size": 20
            }
        }
    },
    "_source": ["perenimi", "eesnimi", "perenimed", "eesnimed", "sünd", "surm", "id", "pereseosID", "pereseos.kirjed.kirje"]
}
'

curl -X GET "https://Delfi:B68-xvu-gds-HA8@94abc9318c712977e8c684628aa5ea0f.us-east-1.aws.found.io:9243/persons/_search?pretty" -H 'Content-Type: application/json' -d'
{
    "query" : {
        "bool" : {
            "must" : {
                "multi_match" : {
                    "query": "mets",
                    "fields": [ "perenimi", "eesnimi", "perenimed", "eesnimed", "sünd", "surm", "id", "pereseosID" ],
                    "operator": "and",
                    "type": "cross_fields"
                }
            },
            "filter": { "term": { "kivi": "1" } }
        }
    },
    "sort": { "perenimi.raw": "asc", "eesnimi.raw": "asc" },
    "_source": [
        "perenimi", "eesnimi", "isanimi", "emanimi", "perenimed", "eesnimed",
        "sünd", "surm", "id",
        "kirjed.kirje", "kirjed.allikas",
        "pereseosID", "pereseos.kirjed.kirje", "pereseos.nimekiri",
        "tahvel", "tulp", "rida", "tahvlikirje",
        "ohvitser", "evokirje"
    ]
}
'
