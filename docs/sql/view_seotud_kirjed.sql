CREATE OR REPLACE VIEW seotud_kirjed
AS 
  SELECT i1.isikukood  AS isikukood,
         i1.kirje      AS kirje,
         IFNULL(GROUP_CONCAT(
           CONCAT( '', s.isikukood2, ' ', s.vastasseos, ': ', i2.kirje ) SEPARATOR '\n'
         ), '')        AS seosed,
         i1.perenimi   AS perenimi,
         i1.eesnimi    AS eesnimi,
         i1.isanimi    AS isanimi,
         i1.sünd       AS sünd,
         i1.surm       AS surm,
         i1.rel        AS rel,
         i1.mr         AS mr,
         i1.attn       AS attn,
         i1.kivi       AS kivi,
         i1.mittekivi  AS mittekivi,
         i1.seos       AS seos,
         i1.seoseliik  AS seoseliik,
         i1.kommentaar AS kommentaar,
         i1.updated    AS updated,
         i1.user       AS user
  FROM kirjed i1 
  LEFT JOIN seosed s ON i1.isikukood = s.isikukood1
  LEFT JOIN kirjed i2 ON i2.isikukood = s.isikukood2
  GROUP BY  i1.isikukood;