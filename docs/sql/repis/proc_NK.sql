DELIMITER ;; -- NK_refresh

  CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.proc_NK_refresh(
    IN _persoon CHAR(10))
  proc_label:BEGIN

    -- Declare variables to hold diagnostics area information
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
      BEGIN
        GET DIAGNOSTICS CONDITION 1
          code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        INSERT INTO z_queue (task, params) values (code, msg);
      END;


    UPDATE repis.kirjed k_u LEFT JOIN
    (
      SELECT k0.persoon
      , SUBSTRING_INDEX(group_concat(
          if(k0.perenimi = ''   OR a.prioriteetPerenimi = 0,
            NULL, UPPER(k0.perenimi))
          ORDER BY a.prioriteetPerenimi DESC SEPARATOR ';'), ';', 1)
          AS perenimi
      , SUBSTRING_INDEX(group_concat(
          if(k0.eesnimi = ''    OR a.prioriteetEesnimi  = 0,
            NULL, REPLACE(UPPER(k0.eesnimi),'ALEKSANDR','ALEKSANDER'))
          ORDER BY a.prioriteetEesnimi  DESC SEPARATOR ';'), ';', 1)
          AS eesnimi
      , SUBSTRING_INDEX(group_concat(
          if(k0.isanimi = ''    OR a.prioriteetIsanimi  = 0,
            NULL, UPPER(k0.isanimi))
          ORDER BY a.prioriteetIsanimi  DESC SEPARATOR ';'), ';', 1)
          AS isanimi
      , SUBSTRING_INDEX(group_concat(
          if(k0.emanimi = ''    OR a.prioriteetEmanimi  = 0,
            NULL, UPPER(k0.emanimi))
          ORDER BY a.prioriteetEmanimi  DESC SEPARATOR ';'), ';', 1)
          AS emanimi
      , SUBSTRING_INDEX(group_concat(
          if(k0.sünd = ''       OR a.prioriteetSünd     = 0,
            NULL, k0.sünd)
          ORDER BY a.prioriteetSünd     DESC SEPARATOR ';'), ';', 1)
          AS sünd
      , SUBSTRING_INDEX(group_concat(
          if(k0.surm = ''       OR a.prioriteetSurm     = 0,
            NULL, k0.surm)
          ORDER BY a.prioriteetSurm     DESC SEPARATOR ';'), ';', 1)
          AS surm
      FROM repis.kirjed k0
      LEFT JOIN allikad a ON a.kood = k0.allikas
      WHERE k0.persoon = _persoon
        AND k0.kirjekood != _persoon
        AND k0.EkslikKanne != '!'
        AND k0.EiArvesta != '!'
      GROUP BY k0.persoon
    ) AS nimekuju ON nimekuju.persoon = k_u.persoon
    SET k_u.perenimi = ifnull(nimekuju.perenimi, '')
      , k_u.eesnimi = ifnull(nimekuju.eesnimi, '')
      , k_u.isanimi = ifnull(nimekuju.isanimi, '')
      , k_u.emanimi = ifnull(nimekuju.emanimi, '')
      , k_u.sünd = ifnull(if(nimekuju.sünd = '-', '', nimekuju.sünd), '')
      , k_u.surm = ifnull(if(nimekuju.surm = '-', '', nimekuju.surm), '')
      , k_u.kirje = repis.desktop_person_text(
          nimekuju.perenimi, nimekuju.eesnimi,
          nimekuju.isanimi, nimekuju.emanimi,
          nimekuju.sünd, nimekuju.surm
        ) COLLATE utf8_estonian_ci
    WHERE k_u.kirjekood = _persoon
    ;

  END;;

DELIMITER ;


DELIMITER ;; -- skeleton mass NK_refresh

  CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.temp_NK_refresh()
  proc_label:BEGIN

    DECLARE _persoon CHAR(10);
    DECLARE finished INTEGER DEFAULT 0;
    -- Declare variables to hold diagnostics area information
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    DECLARE cur1 CURSOR FOR
        SELECT persoon FROM repis.kirjed WHERE EiArvesta = '!';
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
      BEGIN
        GET DIAGNOSTICS CONDITION 1
          code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        INSERT INTO z_queue (task, params) values (code, msg);
      END;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    OPEN cur1;
    read_loop: LOOP
      SET _persoon = NULL;
      FETCH cur1 INTO _persoon;
      CALL repis.proc_NK_refresh(_persoon);
      IF finished = 1 THEN
          LEAVE read_loop;
      END IF;
    END LOOP;
    CLOSE cur1;
    SET finished = 0;

  END;;

DELIMITER ;
