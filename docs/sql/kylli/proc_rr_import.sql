DELIMITER ;;

CREATE OR REPLACE PROCEDURE import_from_rr(IN _ik CHAR(10), IN _user VARCHAR(50))
BEGIN
    DECLARE _ik2 CHAR(10);

    SELECT seos INTO _ik2 FROM rahvastikuregister WHERE kirjekood = _ik;

    INSERT IGNORE INTO kirjed SET isikukood = _ik, user = _user;

    UPDATE kirjed k
    LEFT JOIN rahvastikuregister rk on rk.kirjekood = k.isikukood
    SET
      k.kirje = concat_ws( '. ',
        concat_ws(', ', rk.perenimi, rk.eesnimi, rk.isanimi),
        if (rk.sünd is null, null, concat('Sünd: ', rk.sünd)),
        if (rk.sünnikoht is null, null, concat('Sünnikoht: ', rk.sünnikoht)),
        if (rk.surm is null, null, concat('Surm: ', rk.surm)),
        if (rk.surmakoht is null, null, concat('Surmakoht: ', rk.surmakoht)),
        if (rk.allikas is null, null, concat('Isikukood: ', rk.allikas))
      ),
      k.perenimi = ifnull(rk.perenimi, ''),
      k.eesnimi = ifnull(rk.eesnimi, ''),
      k.isanimi = ifnull(rk.isanimi, ''),
      k.sünd = ifnull(rk.sünd, ''),
      k.surm = ifnull(rk.surm, ''),
      k.allikas = 'RR',
      k.user = _user
    WHERE rk.kirjekood = _ik;

    IF _ik2 IS NOT NULL THEN
      INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task, user)
      VALUES (_ik, _ik2, 'Create connections', _user);
    END IF;


END;;
DELIMITER ;
