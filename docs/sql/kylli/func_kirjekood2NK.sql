DELIMITER ;;
CREATE OR REPLACE FUNCTION kirjekood2nk(
    _kk CHAR(10)
) RETURNS CHAR(10) CHARSET utf8
BEGIN
	SET @nk = NULL;

	select nk.isikukood into @nk
	from kirjed nk
	right join kirjed k on k.emi_id = nk.emi_id
	where k.isikukood = _kk
	and nk.allikas = 'Nimekujud'
  limit 1;

    RETURN @nk;
END;;
DELIMITER ;
