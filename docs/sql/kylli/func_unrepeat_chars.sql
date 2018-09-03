DELIMITER ;;
CREATE OR REPLACE FUNCTION unrepeat(
    _word VARCHAR(100)
) RETURNS VARCHAR(100) CHARSET utf8
BEGIN

    DECLARE i INTEGER;
    DECLARE _out VARCHAR(100);
    SET i = 1;
    SET _out = '';
    
    SET _word = replace(_word, 'TH', 'T');
    SET _word = replace(_word, 'SH', 'Š');
    SET _word = replace(_word, 'CH', 'Š');
    SET _word = replace(_word, 'ZH', 'Š');
    SET _word = replace(_word, 'TZ', 'Š');
    SET _word = replace(_word, 'S' , 'Š');
    SET _word = replace(_word, 'Z' , 'Š');
    SET _word = replace(_word, 'Ž' , 'Š');
    SET _word = replace(_word, 'C' , 'Š');
    SET _word = replace(_word, 'A', 'Ẵ');
    SET _word = replace(_word, 'E', 'Ẵ');
    SET _word = replace(_word, 'I', 'Ẵ');
    SET _word = replace(_word, 'O', 'Ẵ');
    SET _word = replace(_word, 'U', 'Ẵ');
    SET _word = replace(_word, 'Õ', 'Ẵ');
    SET _word = replace(_word, 'Ä', 'Ẵ');
    SET _word = replace(_word, 'Ö', 'Ẵ');
    SET _word = replace(_word, 'Ü', 'Ẵ');

    myloop: WHILE (i <= LENGTH(_word)) DO
        SET _out = concat(_out, SUBSTRING(_word, i, 1));
        IF SUBSTRING(_word, i, 1) = SUBSTRING(_word, i+1, 1) THEN
            SET i = i + 1;
        END IF;
        SET i = i + 1;
    END WHILE; 

    RETURN(_out);

END;;
DELIMITER ;
