DELIMITER ;;

CREATE OR REPLACE FUNCTION `func_order_est`(
	`_word` VARCHAR(100)
)
RETURNS VARCHAR(200) CHARSET utf8 COLLATE utf8_estonian_ci
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
BEGIN

    DECLARE i INTEGER;
    DECLARE _out VARCHAR(200);
    SET i = 0;
    SET _out = '';

    SET _out = UPPER(_word);

    SET _out = REPLACE(_out, ' ', '00');
    SET _out = REPLACE(_out, '-', '00');
    SET _out = REPLACE(_out, 'A', '01');
    SET _out = REPLACE(_out, 'B', '02');
    SET _out = REPLACE(_out, 'C', '03');
    SET _out = REPLACE(_out, 'D', '04');
    SET _out = REPLACE(_out, 'E', '05');
    SET _out = REPLACE(_out, 'F', '06');
    SET _out = REPLACE(_out, 'G', '07');
    SET _out = REPLACE(_out, 'H', '08');
    SET _out = REPLACE(_out, 'I', '09');
    SET _out = REPLACE(_out, 'J', '10');
    SET _out = REPLACE(_out, 'K', '11');
    SET _out = REPLACE(_out, 'L', '12');
    SET _out = REPLACE(_out, 'M', '13');
    SET _out = REPLACE(_out, 'N', '14');
    SET _out = REPLACE(_out, 'O', '15');
    SET _out = REPLACE(_out, 'P', '16');
    SET _out = REPLACE(_out, 'Q', '17');
    SET _out = REPLACE(_out, 'R', '18');
    SET _out = REPLACE(_out, 'S', '19');
    SET _out = REPLACE(_out, 'Š', '20');
    SET _out = REPLACE(_out, 'Z', '21');
    SET _out = REPLACE(_out, 'Ž', '22');
    SET _out = REPLACE(_out, 'T', '23');
    SET _out = REPLACE(_out, 'U', '24');
    SET _out = REPLACE(_out, 'V', '25');
    SET _out = REPLACE(_out, 'W', '26');
    SET _out = REPLACE(_out, 'Õ', '27');
    SET _out = REPLACE(_out, 'Ä', '28');
    SET _out = REPLACE(_out, 'Ö', '29');
    SET _out = REPLACE(_out, 'Ü', '30');
    SET _out = REPLACE(_out, 'X', '31');
    SET _out = REPLACE(_out, 'Y', '32');    

    RETURN(_out);

END;

;; 
DELIMITER ;


