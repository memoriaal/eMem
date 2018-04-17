DELIMITER ;;

CREATE OR REPLACE PROCEDURE rollback_prior_to(IN _ik CHAR(10), IN _ts TIMESTAMP, IN _user VARCHAR(50))
BEGIN
  -- DECLARE finished INTEGER DEFAULT 0;

  DECLARE _attn         ENUM('!','');
  DECLARE _kirje        TEXT;
  DECLARE _huk          ENUM('!','');
  DECLARE _rel          ENUM('!','');
  DECLARE _mr           ENUM('!','');
  DECLARE _kivi         ENUM('!','');
  DECLARE _mittekivi    ENUM('!','');
  DECLARE _perenimi     VARCHAR(50);
  DECLARE _eesnimi      VARCHAR(50);
  DECLARE _isanimi      VARCHAR(50);
  DECLARE _sünd         VARCHAR(50);
  DECLARE _surm         VARCHAR(50);
  DECLARE _märksõna     VARCHAR(100);
  DECLARE _kommentaar   VARCHAR(2000);
  DECLARE _rahvus       VARCHAR(50);
  DECLARE _perekood     VARCHAR(20);
  DECLARE _allikas      VARCHAR(20);
  DECLARE _sugu         ENUM('M','N','');
  DECLARE _nimekiri     VARCHAR(50);
  DECLARE _ekslikkanne  ENUM('!','');

  DECLARE cur1 CURSOR FOR
    SELECT
      attn, kirje, huk, rel, mr, kivi, mittekivi, perenimi, eesnimi,
      isanimi, sünd, surm, märksõna, kommentaar, rahvus, perekood, allikas,
      sugu, nimekiri, ekslikkanne
    FROM kirjed_audit_log
    WHERE isikukood = _ik AND updated < _ts
    ORDER BY updated DESC
    LIMIT 1;
  -- DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
  OPEN cur1;
  FETCH cur1 INTO
    _attn, _kirje, _huk, _rel, _mr, _kivi, _mittekivi, _perenimi, _eesnimi,
    _isanimi, _sünd, _surm, _märksõna, _kommentaar, _rahvus, _perekood, _allikas,
    _sugu, _nimekiri, _ekslikkanne;

  UPDATE kirjed k
  SET k.attn = _attn, k.kirje = _kirje, k.huk = _huk, k.rel = _rel, k.mr = _mr, k.kivi = _kivi, k.mittekivi = _mittekivi, k.perenimi = _perenimi, k.eesnimi = _eesnimi,
  k.isanimi = _isanimi, k.sünd = _sünd, k.surm = _surm, k.märksõna = _märksõna, k.kommentaar = _kommentaar, k.rahvus = _rahvus, k.perekood = _perekood, k.allikas = _allikas,
  k.sugu = _sugu, k.nimekiri = _nimekiri, k.ekslikkanne = _ekslikkanne, k.user = _user
  WHERE k.isikukood = _ik;

END;;

DELIMITER ;
