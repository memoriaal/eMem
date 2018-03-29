DELIMITER ;;
CREATE OR REPLACE PROCEDURE remove_record(
    _ik char(10)
)
BEGIN

  UPDATE `pereregister` SET seos = isikukood WHERE seos = _ik;
  UPDATE `rahvastikuregister` SET seos = kirjekood WHERE seos = _ik;
  DELETE FROM `kirjesildid` WHERE `kirjekood` = _ik;
  DELETE FROM seosed WHERE isikukood1 = _ik;
  DELETE FROM seosed WHERE isikukood2 = _ik;
  INSERT INTO kustutatud_kirjed SELECT * FROM `kirjed` WHERE `Isikukood` = _ik;
  DELETE FROM `kirjed` WHERE `Isikukood` = _ik;

END;;
DELIMITER ;
