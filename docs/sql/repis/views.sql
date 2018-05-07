CREATE OR REPLACE VIEW repis.a_persoonid
AS
  SELECT kn.persoon, kn.perenimi, kn.eesnimi, kn.isanimi, kn.emanimi, kn.sünd, kn.surm
       , group_concat(concat(kk.kirjekood, ': ', kk.kirje) SEPARATOR '\n') as Kirjed
  FROM kirjed kn
  LEFT JOIN kirjed kk ON kk.persoon = kn.persoon AND kk.kirjekood != kn.kirjekood
  WHERE kn.allikas = 'Nimekujud'
  GROUP BY kn.persoon;


CREATE OR REPLACE VIEW repis.my_desktop
AS
SELECT * FROM repis.desktop WHERE created_by = user();
