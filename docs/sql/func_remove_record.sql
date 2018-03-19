DELIMITER ;;
CREATE OR REPLACE PROCEDURE remove_record(
    _ik char(10)
)
BEGIN

  UPDATE `pereregister` SET seos = NULL, import = 0 WHERE seos = _ik;
  DELETE FROM `kirjesildid` WHERE `kirjekood` = _ik;
  DELETE FROM seosed WHERE isikukood1 = _ik;
  DELETE FROM seosed WHERE isikukood2 = _ik;
  DELETE FROM `kirjed` WHERE `Isikukood` = _ik;

END;;
DELIMITER ;
