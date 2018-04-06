DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE `NK_refresh`(IN _emi_id INT(11) UNSIGNED)
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
    AND k.MR != '!'
    AND k.Puudulik != '!'
    AND k.Allikas NOT IN (
      SELECT Kood FROM allikad
      WHERE nonPerson = 1
    );

    IF @cnt = 0 THEN
      LEAVE proc_label;
    END IF;

    INSERT INTO kirjed (isikukood, emi_id, allikas)
    SELECT lpad(max(right(isikukood, 7))+1, 10, 'NK-0000000') AS isikukood
         , _emi_id as emi_id 
         , 'Nimekujud' as allikas
      FROM kirjed where allikas = 'Nimekujud';

  END IF;


  update kirjed k left join
  (
        SELECT nk.isikukood
        , SUBSTRING_INDEX(group_concat(
            if(k.perenimi = ''   OR a.prioriteetPerenimi = 0, '', UPPER(k.perenimi))
            ORDER BY a.prioriteetPerenimi DESC SEPARATOR ';'), ';', 1)
            AS perenimi
        , SUBSTRING_INDEX(group_concat(
            if(k.eesnimi = ''    OR a.prioriteetEesnimi  = 0,  '', REPLACE(UPPER(k.eesnimi),'ALEKSANDR','ALEKSANDER'))
            ORDER BY a.prioriteetEesnimi  DESC SEPARATOR ';'), ';', 1)
            AS eesnimi
        , SUBSTRING_INDEX(group_concat(
            if(k.isanimi = ''    OR a.prioriteetIsanimi  = 0,  '', UPPER(k.isanimi))
            ORDER BY a.prioriteetIsanimi  DESC SEPARATOR ';'), ';', 1)
            AS isanimi
        , SUBSTRING_INDEX(group_concat(
            if(k.emanimi = ''    OR a.prioriteetEmanimi  = 0,  '', UPPER(k.emanimi))
            ORDER BY a.prioriteetEmanimi  DESC SEPARATOR ';'), ';', 1)
            AS emanimi
        , SUBSTRING_INDEX(group_concat(
            if(k.sünd = ''       OR a.prioriteetSünd     = 0,  '', LEFT(k.sünd,4))
            ORDER BY a.prioriteetSünd     DESC SEPARATOR ';'), ';', 1)
            AS sünd
        , SUBSTRING_INDEX(group_concat(
            if(k.surm = ''       OR a.prioriteetSurm     = 0,  '', LEFT(k.surm,4))
            ORDER BY a.prioriteetSurm     DESC SEPARATOR ';'), ';', 1)
            AS surm
        from kirjed k
        left join v_prioriteedid a on a.kood = k.allikas
        right join kirjed nk on nk.emi_id = k.emi_id
        where k.EkslikKanne = ''
        and k.Puudulik = ''
        and k.Peatatud = ''
        and k.allikas NOT IN ('Nimekujud', 'R86')
        and nk.isikukood = @ik
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
  where k.isikukood = @ik
  and k.allikas = 'Nimekujud';


END;;
DELIMITER ;
