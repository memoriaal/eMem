#!/bin/bash

. ~/credentials.txt

csv_filename="/paringud/$(date +%Y%m%d_%H%M%S)_memoriaal_ee.csv"

mysql -u"${M_MYSQL_U}" -p"${M_MYSQL_P}" aruanded<<EOFMYSQL
SELECT * from aruanded.memoriaal_ee
INTO OUTFILE '${csv_filename}'
CHARACTER SET utf8
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
EOFMYSQL

INDEX=persons SOURCE=${csv_filename} ES_CREDENTIALS='${ELASTIC_C}' node ~/scripts/import_once.js

# rm ${csv_filename}
