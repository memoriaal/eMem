WHERE `Kirje` REGEXP '
  (?:[^0-9][^0-9][^0-9])
  (
    [0-3]?[0-9]\\. [0-1]?[0-9]\\.1?[89]?[0-9]?[0-9]
   |[0-3]?[0-9]\\.[0-1]?[0-9]\\. 1?[89]?[0-9]?[0-9]
                 |[0-1]?[0-9]\\. 1?[89]?[0-9]?[0-9]
  )
  (?:[^0-9][^0-9])
';
  
  
WHERE `Kirje` REGEXP '
  (?:[^0-9][^0-9][^0-9])([0-3]?[0-9]\. [0-1]?[0-9]\.1?[89]?[0-9]?[0-9]|[0-3]?[0-9]\.[0-1]?[0-9]\. 1?[89]?[0-9]?[0-9]|[0-1]?[0-9]\. 1?[89]?[0-9]?[0-9])(?:[^0-9][^0-9])
';
  
  
[0-3]?[0-9]\.[0-1]?[0-9]\.1?[89]?[0-9]?[0-9]
|[0-3]?[0-9]\.[0-1]?[0-9]\.1?[89]?[0-9]?[0-9]
|[0-1]?[0-9]\.1?[89]?[0-9]?[0-9]
|1[89][0-9][0-9]
)
(?:[^0-9][^0-9])(.*)

([0-9]{2})\.([0-9]{2})\.([0-9]{4})  $3-$2-$1

sulgudes nimi semikaga
(.*) \((.*)\) ?(.*)       ->     $1;$2 $3