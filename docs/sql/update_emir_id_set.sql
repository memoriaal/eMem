-- Find EMI records referencing same descendant
SELECT e1.id, e1.ref, e1.id_set, e2.id, e2.ref, e2.id_set
  FROM EMIR e1 LEFT JOIN EMIR e2 ON e1.ref = e2.ref AND e2.id > e1.id
 WHERE e2.ref IS NOT NULL
;
-- resolve double referencing
UPDATE EMIR e1 LEFT JOIN EMIR e2 ON e1.ref = e2.ref AND e2.id > e1.id
   SET e1.ref = e2.id
 WHERE e2.ref IS NOT NULL
;


UPDATE EMIR e1 
  LEFT JOIN EMIR e2  ON e2.ref  = e1.id
  LEFT JOIN EMIR e3  ON e3.ref  = e2.id
  LEFT JOIN EMIR e4  ON e4.ref  = e3.id
  LEFT JOIN EMIR e5  ON e5.ref  = e4.id
  LEFT JOIN EMIR e6  ON e6.ref  = e5.id
  LEFT JOIN EMIR e7  ON e7.ref  = e6.id
  LEFT JOIN EMIR e8  ON e8.ref  = e7.id
  LEFT JOIN EMIR e9  ON e9.ref  = e8.id
  LEFT JOIN EMIR e10 ON e10.ref = e9.id
  LEFT JOIN EMIR e11 ON e11.ref = e10.id
  LEFT JOIN EMIR e12 ON e12.ref = e11.id
  LEFT JOIN EMIR e13 ON e13.ref = e12.id
  LEFT JOIN EMIR e14 ON e14.ref = e13.id
  LEFT JOIN EMIR e15 ON e15.ref = e14.id
  LEFT JOIN EMIR e16 ON e16.ref = e15.id
  LEFT JOIN EMIR e17 ON e17.ref = e16.id
  LEFT JOIN EMIR e18 ON e18.ref = e17.id
  LEFT JOIN EMIR e19 ON e19.ref = e18.id
  LEFT JOIN EMIR e20 ON e20.ref = e19.id
SET e1.id_set = CONCAT_WS(','
  , e1.id,  e2.id,  e3.id,  e4.id,  e5.id
  , e6.id,  e7.id,  e8.id,  e9.id,  e10.id
  , e11.id, e12.id, e13.id, e14.id, e15.id
  , e16.id, e17.id, e18.id, e19.id, e20.id
)
;