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
      k.kommentaar = concat(rk.märkused1, '; ', rk.märkused2),
      k.allikas = 'RK'
    WHERE rk.isikukood = _ik;
    
    IF _ik2 IS NOT NULL THEN
      INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task, user)
      VALUES (_ik, _ik2, 'Create connections', 'import_from_rk');
    END IF;
    

END;;
DELIMITER ;

