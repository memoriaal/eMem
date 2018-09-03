DELIMITER ;;
CREATE OR REPLACE FUNCTION find_by_eid(
    _emi_id INT(11) UNSIGNED
) RETURNS CHAR(10) CHARSET utf8
BEGIN
	SET @nk = NULL;
	SET @emi_id = NULL;

  SELECT id INTO @emi_id
  FROM EMIR e
  WHERE find_in_set(_emi_id, e.id_set)
  AND e.ref IS NULL;

	select nk.isikukood into @nk
	from kirjed nk
	where nk.emi_id = @emi_id
	and nk.allikas = 'Nimekujud'
  limit 1;

  RETURN @nk;
END;;
DELIMITER ;
