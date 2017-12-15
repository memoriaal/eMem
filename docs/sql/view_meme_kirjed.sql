CREATE OR REPLACE VIEW meme_kirjed AS
SELECT
  m.id         AS id,
  m.Kommentaar AS meme_kommentaar,
  m.Seos       AS seos,
  m.Perenimi   AS perenimi,
  m.Eesnimi    AS eesnimi,
  m.Sünd       AS sünd,
  m.Surm       AS surm,
  m.Nimestik   AS nimestik,
  rk.otmetki   AS otmetki,
  k.Isikukood  AS isikukood,
  k.Kivi       AS kivi,
  k.Mittekivi  AS mittekivi,
  k.REL        AS rel,
  k.MR         AS mr,
  k.Kirje      AS kirje,
  k.kommentaar AS kirje_kommentaar,
  k.SeosedCSV  AS seosedcsv,
  k.Nimekiri   AS nimekiri
FROM
  MEMENTO m 
  LEFT JOIN kirjed k 
    ON 
      m.Seos = k.Isikukood 
      OR ( k.Eesnimi = m.Eesnimi 
        AND k.Perenimi = m.Perenimi 
        AND left(k.Sünd, 4) = left(m.Sünd, 4)
        AND left(k.Surm, 4) = left(m.Surm, 4)
      )
  LEFT JOIN repr_kart rk ON rk.seos = k.isikukood
WHERE    m.Surm <> ''
  AND    k.Surm <> ''
ORDER BY k.REL DESC,
         k.MR DESC,
         k.Kivi DESC,
         k.Mittekivi DESC,
         k.Surm DESC
;