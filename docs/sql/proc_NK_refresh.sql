DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE `update_NK`(IN _emi_id INT(11) UNSIGNED, IN _user VARCHAR(50))
proc_label:BEGIN

  SET @ik = NULL;

  SELECT isikukood INTO @ik
  FROM kirjed
  WHERE emi_id = _emi_id
  AND allikas = 'Nimekujud'
  LIMIT 1;

  -- Kui pole NK kirjet
  IF @ik IS NULL THEN

    SELECT COUNT(1) INTO @cnt FROM kirjed k
    WHERE k.emi_id = _emi_id
    -- AND k.MR != '!'
    AND k.Puudulik != '!'
    AND k.Allikas NOT IN (
      SELECT Kood FROM allikad
      WHERE nonPerson = 1
    );

    IF @cnt = 0 THEN
      LEAVE proc_label;
    END IF;

    SELECT lpad(max(right(isikukood, 7))+1, 10, 'NK-0000000') INTO @ik
      FROM kirjed where allikas = 'Nimekujud';

    INSERT INTO kirjed (isikukood, emi_id, allikas, user)
    VALUES (@ik, _emi_id, 'Nimekujud', _user);

    SELECT isikukood INTO @seos FROM kirjed k
    WHERE k.emi_id = _emi_id
    -- AND k.MR != '!'
    AND k.Puudulik != '!'
    AND k.Allikas NOT IN (
      SELECT Kood FROM allikad
      WHERE nonPerson = 1
    )
    AND k.isikukood != @ik
    LIMIT 1;

    INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task, user)
    VALUES (@ik, @seos, 'Create connections', _user);
    -- INSERT IGNORE INTO z_queue (emi_id, task, params, user)
    -- VALUES (_emi_id, 'Refresh NK', NULL, _user);

  END IF;


  CALL NK_refresh(@ik);

END;;
DELIMITER ;



DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE NK_refresh(IN _ik CHAR(10))
BEGIN
  update kirjed k left join
  (
        SELECT nk.isikukood
        , SUBSTRING_INDEX(group_concat(
            if(k.perenimi = ''   OR a.prioriteetPerenimi = 0,  NULL, UPPER(k.perenimi))
            ORDER BY a.prioriteetPerenimi DESC SEPARATOR ';'), ';', 1)
            AS perenimi
        , SUBSTRING_INDEX(group_concat(
            if(k.eesnimi = ''    OR a.prioriteetEesnimi  = 0,  NULL, REPLACE(UPPER(k.eesnimi),'ALEKSANDR','ALEKSANDER'))
            ORDER BY a.prioriteetEesnimi  DESC SEPARATOR ';'), ';', 1)
            AS eesnimi
        , SUBSTRING_INDEX(group_concat(
            if(k.isanimi = ''    OR a.prioriteetIsanimi  = 0,  NULL, UPPER(k.isanimi))
            ORDER BY a.prioriteetIsanimi  DESC SEPARATOR ';'), ';', 1)
            AS isanimi
        , SUBSTRING_INDEX(group_concat(
            if(k.emanimi = ''    OR a.prioriteetEmanimi  = 0,  NULL, UPPER(k.emanimi))
            ORDER BY a.prioriteetEmanimi  DESC SEPARATOR ';'), ';', 1)
            AS emanimi
        , SUBSTRING_INDEX(group_concat(
            if(k.sünd = ''       OR a.prioriteetSünd     = 0,  NULL, k.sünd)
            ORDER BY a.prioriteetSünd     DESC SEPARATOR ';'), ';', 1)
            AS sünd
        , SUBSTRING_INDEX(group_concat(
            if(k.surm = ''       OR a.prioriteetSurm     = 0,  NULL, k.surm)
            ORDER BY a.prioriteetSurm     DESC SEPARATOR ';'), ';', 1)
            AS surm
        from kirjed k
        left join v_prioriteedid a on a.kood = k.allikas
        right join kirjed nk on nk.emi_id = k.emi_id
        where k.EkslikKanne = ''
        and k.Puudulik = ''
        and k.Peatatud = ''
        and k.allikas != 'Nimekujud'
        and k.allikas NOT IN (select kood from allikad where nonperson = 1)
        and nk.isikukood = _ik
        group by k.emi_id
  ) as nimekuju on nimekuju.isikukood = k.isikukood
  set k.perenimi = ifnull(nimekuju.perenimi, '')
    , k.eesnimi = ifnull(nimekuju.eesnimi, '')
    , k.isanimi = ifnull(nimekuju.isanimi, '')
    , k.emanimi = ifnull(nimekuju.emanimi, '')
    , k.sünd = ifnull(nimekuju.sünd, '')
    , k.surm = ifnull(nimekuju.surm, '')
    , kirje =
      concat_ws('. '
        , concat_ws(', '
          , if(nimekuju.perenimi='',NULL,nimekuju.perenimi)
          , if(nimekuju.eesnimi='',NULL,nimekuju.eesnimi)
          , if(nimekuju.isanimi='',NULL,nimekuju.isanimi)
          , if(nimekuju.emanimi='',NULL,nimekuju.emanimi)
        )
        , concat_ws(' - '
          , if(nimekuju.sünd='', NULL, concat('Sünd ', nimekuju.sünd))
          , if(nimekuju.surm='', NULL, concat('Surm ', nimekuju.surm))
        )
      )
  where k.isikukood = _ik
  and k.allikas = 'Nimekujud';


END;;
DELIMITER ;


DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE NK_refresh_all()
BEGIN

    DECLARE _ik CHAR(10);
    DECLARE finished INTEGER DEFAULT 0;

    DECLARE cur1 CURSOR FOR
        SELECT isikukood
        FROM kirjed
        WHERE allikas = 'Nimekujud';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    OPEN cur1;
    read_loop: LOOP
        FETCH cur1 INTO _ik;
        IF finished = 1 THEN
            LEAVE read_loop;
        END IF;

        CALL NK_refresh(_ik);

    END LOOP;
    CLOSE cur1;
    SET finished = 0;
END;;
DELIMITER ;
