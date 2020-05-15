DELIMITER $$

DROP PROCEDURE IF EXISTS `log_msg`$$

CREATE PROCEDURE log_msg(_key, _msg VARCHAR(255))
BEGIN
  INSERT INTO log_msg (key, msg, usr)
  VALUES (_key, _msg, SYSTEM_USER());
END $$

DELIMITER ;
CALL log_msg('foo');
