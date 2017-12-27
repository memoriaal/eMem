DELIMITER ;;

CREATE OR REPLACE PROCEDURE import_from_rk(IN _ik CHAR(10))
BEGIN
    DECLARE _ik2 CHAR(10);

    SELECT seos INTO _ik2 FROM repr_kart WHERE isikukood = _ik;
    
    INSERT IGNORE INTO kirjed SET isikukood = _ik;

    UPDATE kirjed k
    LEFT JOIN repr_kart rk on rk.isikukood = k.isikukood 
    SET
      k.kirje = CONCAT(
        rk.f, ', ', rk.i, ', ', rk.o, '. ', 
        'Sünd: ', rk.sa, ', ', `NSV, ANSV, oblast, krai, kubermang, kond`, ', ', `sünnilinn, vald, rajoon`, 
        '. Surm: ', rk.surm, '. \n', rk.otmetki
      ),
      k.kivi = rk.kivi, 
      k.mittekivi = rk.mittekivi, 
      k.REL = rk.REL, 
      k.MR = rk.MR,
      k.perenimi = rk.perenimi,
      k.eesnimi = rk.eesnimi,
      k.isanimi = rk.o,
      k.sünd = rk.sa,
      k.surm = rk.surm,
      k.kommentaar = concat(rk.märkused1, '; ', rk.märkused2)
    WHERE rk.isikukood = _ik;
    
    INSERT INTO z_queue (isikukood1, isikukood2, task, params, user)
    VALUES (_ik, _ik2, 'create connections', '', 'import_from_rk');

END;;
DELIMITER ;
