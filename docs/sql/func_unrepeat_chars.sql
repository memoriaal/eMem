DELIMITER ;;
CREATE OR REPLACE FUNCTION unrepeat(
    _word VARCHAR(100)
) RETURNS VARCHAR(100) CHARSET utf8
BEGIN

    DECLARE i INTEGER;
    DECLARE _out VARCHAR(100);
    SET i = 1;
    SET _out = '';
    
    SET _word = replace(_word, 'th', 't');
    SET _word = replace(_word, 'sh', 'š');
    SET _word = replace(_word, 'ch', 'š');
    SET _word = replace(_word, 'zh', 'š');
    SET _word = replace(_word, 'tz', 'š');
    SET _word = replace(_word, 's' , 'š');
    SET _word = replace(_word, 'z' , 'š');
    SET _word = replace(_word, 'ž' , 'š');
    SET _word = replace(_word, 'c' , 'š');
    SET _word = replace(_word, 'a', 'a');
    SET _word = replace(_word, 'e', 'a');
    SET _word = replace(_word, 'i', 'a');
    SET _word = replace(_word, 'o', 'a');
    SET _word = replace(_word, 'u', 'a');
    SET _word = replace(_word, 'õ', 'a');
    SET _word = replace(_word, 'ä', 'a');
    SET _word = replace(_word, 'ö', 'a');
    SET _word = replace(_word, 'ü', 'a');

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
