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

-- detect shifted emi_id's in kirjed
select * from kirjed k
left join EMIR e on e.id = k.emi_id
where e.ref IS NOT NULL
;

-- resolve shifted emi_id's in kirjed
update kirjed k
left join EMIR e on e.id = k.emi_id
set k.emi_id = e.ref
where e.ref IS NOT NULL
;

UPDATE EMIR e01 
  LEFT JOIN EMIR e02 ON e02.ref = e01.id
  LEFT JOIN EMIR e03 ON e03.ref = e02.id
  LEFT JOIN EMIR e04 ON e04.ref = e03.id
  LEFT JOIN EMIR e05 ON e05.ref = e04.id
  LEFT JOIN EMIR e06 ON e06.ref = e05.id
  LEFT JOIN EMIR e07 ON e07.ref = e06.id
  LEFT JOIN EMIR e08 ON e08.ref = e07.id
  LEFT JOIN EMIR e09 ON e09.ref = e08.id
  LEFT JOIN EMIR e10 ON e10.ref = e09.id
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
  LEFT JOIN EMIR e21 ON e21.ref = e20.id
  LEFT JOIN EMIR e22 ON e22.ref = e21.id
  LEFT JOIN EMIR e23 ON e23.ref = e22.id
  LEFT JOIN EMIR e24 ON e24.ref = e23.id
  LEFT JOIN EMIR e25 ON e25.ref = e24.id
  LEFT JOIN EMIR e26 ON e26.ref = e25.id
  LEFT JOIN EMIR e27 ON e27.ref = e26.id
  LEFT JOIN EMIR e28 ON e28.ref = e27.id
  LEFT JOIN EMIR e29 ON e29.ref = e28.id
SET e01.id_set = CONCAT_WS(','
  , e29.id, e28.id, e27.id, e26.id , e25.id, e24.id, e23.id, e22.id, e21.id, e20.id
  , e19.id, e18.id, e17.id, e16.id , e15.id, e14.id, e13.id, e12.id, e11.id, e10.id
  , e09.id, e08.id, e07.id, e06.id , e05.id, e04.id, e03.id, e02.id, e01.id
)
;