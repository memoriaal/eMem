#!/bin/bash

. ./credentials.txt

for file in test/*.sql; do
    [ -e "${file}" ] || continue

    outfilename="${MYSQL_ODIR}/$(basename ${file})_out.txt"
    echo "=== $(basename ${file}) --> ${outfilename} ==="

    mysql -u"${M_MYSQL_U}" -p"${M_MYSQL_P}" aruanded < ${file} | tee ${outfilename}
done

if [ "$(ps aux | grep amazonaws | wc -l)" = "1" ]; then
  echo establishing tunnel
  ssh -4 -f root@entu.ee -L 3307:entu.cxjegrfpusql.eu-central-1.rds.amazonaws.com:3306 -N
else
  echo allready tunneling
fi

mysqldump -u"${M_MYSQL_U}" -p"${M_MYSQL_P}" aruanded props | mysql -h 127.0.0.1 -P 3307 repis --ssl-ca=scripts/rds-combined-ca-bundle.pem -u"${E_MYSQL_U}" -p"${E_MYSQL_P}" --default-auth=mysql_clear_password
