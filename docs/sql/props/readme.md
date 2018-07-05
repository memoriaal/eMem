lsof -i -n | egrep '\<ssh\>'
ps aux | grep 3307


[michelek@arendus-mi ~]$
          ssh -4 -f root@entu.ee -L 3307:entu.cxjegrfpusql.eu-central-1.rds.amazonaws.com:3306 -N
          mysql -h 127.0.0.1 -P 3307 --ssl-ca=scripts/rds-combined-ca-bundle.pem  -umihkel -p${xxxxxxxx} --default-auth=mysql_clear_password

Mihkels-MacBook-Pro:~ michelek$
          ssh -f root@entu.ee -L 3307:entu.cxjegrfpusql.eu-central-1.rds.amazonaws.com:3306 -N
          mysql -h 127.0.0.1 -P 3307 --ssl-ca=rds-combined-ca-bundle.pem  -umihkel -p${xxxxxxxx} --enable-cleartext-plugin
