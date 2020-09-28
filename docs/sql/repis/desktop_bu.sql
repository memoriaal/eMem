DELIMITER ;; -- desktop_BU

  CREATE OR REPLACE DEFINER=queue@localhost TRIGGER repis.desktop_BU BEFORE UPDATE ON repis.desktop FOR EACH ROW
    proc_label:BEGIN

    DECLARE msg TEXT;

    -- can change only owned records
      IF  OLD.created_by != user()
        AND user() != 'queue@localhost'
        AND user() != 'event_scheduler@localhost'
        THEN
        SELECT concat_ws('\n'
          , 'Mängi oma liivakastis!'
          , user()
        ) INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
      END IF;

    -- no meddling
      SET NEW.created_by = OLD.created_by;
      SET NEW.allikas = OLD.allikas;
      SET NEW.jutt = IF(OLD.jutt = ' - - - ', ' - - - ', NEW.jutt);

    -- cant change the identifier
      IF  NEW.kirjekood != OLD.kirjekood THEN
        SELECT concat_ws('\n'
          , 'Kirjekoode ei saa muuta.'
          , 'Mitte kuidagi ei saa.'
        ) INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
      END IF;

    -- cant remove person from record
      IF NEW.persoon != OLD.persoon AND NEW.persoon = '' THEN
        SELECT concat_ws('\n'
          , 'Kirjelt ei saa persooni ära võtta.'
        ) INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
      END IF;

    -- cant assign person to another person
      IF NEW.persoon != OLD.persoon AND OLD.kirjekood = OLD.persoon THEN
        -- SELECT concat_ws('\n'
        --   , 'Nimekuju kirjet ei saa isikust lahutada.'
        -- ) INTO msg;
        -- SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
        SET NEW.eesnimi = '';
        SET NEW.perenimi = '';
        SET NEW.emanimi = '';
        SET NEW.isanimi = '';
        SET NEW.sünd = '';
        SET NEW.surm = '';
        INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2,  task,                   params, created_by)
        VALUES                           (OLD.persoon, NEW.persoon, 'desktop_join_persons', '',     user());
        INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,                    params, created_by)
        VALUES                           (NEW.persoon, NULL,       'desktop_NK_refresh',    '1',   user());

        LEAVE proc_label;
      END IF;

    -- cant change almost anything but person for original records
      IF OLD.allikas NOT IN ('EMI', 'TS', 'Persoon', 'KR')
        AND user() != 'michelek@localhost'
        AND user() != 'queue@localhost'
        AND user() != 'event_scheduler@localhost'
        AND ( NEW.kirjekood != OLD.kirjekood OR
              NEW.perenimi != OLD.perenimi OR
              NEW.eesnimi != OLD.eesnimi OR
              NEW.isanimi != OLD.isanimi OR
              NEW.emanimi != OLD.emanimi OR
              NEW.sünd != OLD.sünd OR
              NEW.surm != OLD.surm OR
              NEW.matmisaeg != OLD.matmisaeg OR
              NEW.sünnikoht != OLD.sünnikoht OR
              NEW.elukoht != OLD.elukoht OR
              NEW.matmiskoht != OLD.matmiskoht OR
              NEW.`surma põhjus` != OLD.`surma põhjus` OR
              NEW.jutt != OLD.jutt OR
              NEW.välisviide != OLD.välisviide OR
              NEW.kirje != OLD.kirje) THEN
        SELECT concat_ws('\n'
          , 'Registri kirjetel saab muuta ainult persooni koodi!'
        ) INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
      END IF;


    --
    -- Update desktop silts'n'lipiks
    --
    IF NEW.lipik IS NOT NULL THEN
      INSERT IGNORE INTO repis.desk_lipikud (desktop_id, lipik)
      VALUES (NEW.id, NEW.lipik);
      IF row_count() = 0 THEN
        DELETE FROM repis.desk_lipikud WHERE desktop_id = NEW.id AND lipik = NEW.lipik;
      END IF;

      SELECT GROUP_CONCAT(dl.lipik SEPARATOR '; ') INTO @lipikud
      FROM repis.desk_lipikud dl
      WHERE dl.desktop_id = NEW.id;

      SET NEW.lipikud = IFNULL(@lipikud, '');
      SET NEW.lipik = NULL;
    END IF;

    IF NEW.silt IS NOT NULL THEN
      INSERT IGNORE INTO repis.desk_sildid (desktop_id, silt)
      VALUES (NEW.id, NEW.silt);
      IF row_count() = 0 THEN
        DELETE FROM repis.desk_sildid WHERE desktop_id = NEW.id AND silt = NEW.silt;
      END IF;

      SELECT GROUP_CONCAT(ds.silt SEPARATOR '; ') INTO @sildid
      FROM repis.desk_sildid ds
      WHERE ds.desktop_id = NEW.id;

      SET NEW.sildid = IFNULL(@sildid, '');
      SET NEW.silt = NULL;
    END IF;


    --
    -- Prefill names'n'dates'n'kirje of new EMI
    --
    IF OLD.allikas IN ('EMI', 'KR')
       AND OLD.persoon = '' AND NEW.persoon != '' THEN
      IF NEW.perenimi = '' AND NEW.eesnimi  = ''
         AND NEW.isanimi  = '' AND NEW.emanimi  = ''
         AND NEW.sünd     = '' AND NEW.surm     = '' THEN
            SET @perenimi = '', @eesnimi = ''
               , @isanimi = '', @emanimi = ''
               , @sünd = '', @surm = ''
               , @kirje = '', @allikas = '';
            SELECT k.perenimi, k.eesnimi
                 , k.isanimi, k.emanimi
                 , k.sünd, k.surm
                 , k.kirje, k.allikas
              INTO @perenimi, @eesnimi
                 , @isanimi, @emanimi
                 , @sünd, @surm
                 , @kirje, @allikas
              FROM repis.desktop k
             WHERE k.kirjekood = NEW.persoon;

            SET NEW.perenimi = @perenimi, NEW.eesnimi = @eesnimi,
                NEW.isanimi = @isanimi, NEW.emanimi = @emanimi,
                NEW.sünd = @sünd, NEW.surm = @surm;

      END IF;
    END IF;


    --
    -- Recalculate current record
    --
    IF OLD.allikas IN ('EMI', 'Persoon') THEN
      SET NEW.kirje =
        concat_ws('. ',
          repis.desktop_person_text(
              NEW.perenimi, NEW.eesnimi,
              NEW.isanimi, NEW.emanimi,
              NEW.sünd, NEW.surm
            ) COLLATE utf8_estonian_ci,
          if(NEW.jutt IN('', ' - - - '), NULL, NEW.jutt)
        )
      ;
    END IF;


    --
    -- Request recalculation for person that gave away record
    --
    IF NEW.persoon != OLD.persoon AND OLD.persoon != '' THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,            params, created_by)
      VALUES                           (OLD.persoon, NULL,       'desktop_NK_refresh', '1',   user());
    END IF;


    --
    -- Request recalculation for affected person(s)
    --

    IF NEW.persoon != '' THEN
      SET @refresh_requested = 0;

      IF NEW.persoon != OLD.persoon AND @refresh_requested = 0 THEN
        INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,            params, created_by)
        VALUES                           (NEW.persoon, NULL,       'desktop_NK_refresh', '2.1',   user());
        SET @refresh_requested = 1;
      END IF;

      IF (  NEW.eesnimi != OLD.eesnimi
         OR NEW.perenimi != OLD.perenimi
         OR NEW.isanimi != OLD.isanimi
         OR NEW.emanimi != OLD.emanimi
         OR NEW.sünd != OLD.sünd
         OR NEW.surm != OLD.surm
         )
         AND NEW.allikas != 'Persoon' AND @refresh_requested = 0 THEN
            INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,            params, created_by)
            VALUES                           (NEW.persoon, NULL,       'desktop_NK_refresh', '2.2',   user());
            SET @refresh_requested = 1;
      END IF;

    END IF;

    --
    -- Request recalculation for person with changed status
    --
    IF NEW.EkslikKanne != OLD.EkslikKanne
       OR NEW.Kustuta != OLD.Kustuta
       OR NEW.Peatatud != OLD.Peatatud
       OR NEW.EiArvesta != OLD.EiArvesta THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,            params, created_by)
      VALUES                           (OLD.persoon, NULL,       'desktop_NK_refresh', '3',   user());
    END IF;



    --
    -- Clean desktop
    --
    IF NEW.valmis = 'Untsus' THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,            params, created_by)
      VALUES                           (NULL,        NULL,       'desktop_flush', NULL,   user());


    --
    -- Save and clean desktop
    --
    ELSEIF NEW.valmis = 'Valmis' THEN

      -- Save new persons if any
      INSERT INTO repis.kirjed (
        persoon, kirjekood, kirje, legend, perenimi, eesnimi,
        isanimi, emanimi, sünd, surm, allikas,
        matmisaeg, sünnikoht, elukoht, matmiskoht, `surma põhjus`,
        välisviide, EkslikKanne, Peatatud, EiArvesta,
        created_at, created_by,
        KirjePersoon)
      SELECT d.persoon, d.kirjekood, d.kirje, d.legend, d.perenimi, d.eesnimi,
             d.isanimi, d.emanimi, d.sünd, d.surm, d.allikas,
             d.matmisaeg, d.sünnikoht, d.elukoht, d.matmiskoht, d.`surma põhjus`,
             d.välisviide, d.EkslikKanne, d.Peatatud, d.EiArvesta,
             now(), SUBSTRING_INDEX(user(), '@', 1),
             repis.desktop_person_text(
                d.perenimi, d.eesnimi,
                d.isanimi, d.emanimi,
                d.sünd, d.surm
              )
      FROM repis.desktop d
      LEFT JOIN repis.kirjed k ON k.kirjekood = d.kirjekood
      WHERE k.persoon IS NULL
      AND d.persoon = d.kirjekood
      AND d.created_by = user();

      -- Save new records to new persons if any
      INSERT INTO repis.kirjed (
        persoon, kirjekood, kirje, legend, perenimi, eesnimi,
        isanimi, emanimi, sünd, surm, allikas,
        matmisaeg, sünnikoht, elukoht, matmiskoht, `surma põhjus`,
        välisviide, EkslikKanne, Peatatud, EiArvesta,
        created_at, created_by,
        KirjePersoon,
        kirjeJutt)
      SELECT d.persoon, d.kirjekood, d.kirje, d.legend, d.perenimi, d.eesnimi,
             d.isanimi, d.emanimi, d.sünd, d.surm, d.allikas,
             d.matmisaeg, d.sünnikoht, d.elukoht, d.matmiskoht, d.`surma põhjus`,
             d.välisviide, d.EkslikKanne, d.Peatatud, d.EiArvesta,
             now(), SUBSTRING_INDEX(user(), '@', 1),
             if(d.allikas IN ('EMI', 'TS'),
                  repis.desktop_person_text(
                    d2.perenimi, d2.eesnimi,
                    d2.isanimi, d2.emanimi,
                    d2.sünd, d2.surm
                  ),
                  NULL
               ),
             if(d.allikas IN ('EMI', 'TS'), d.jutt, NULL)
      FROM repis.desktop d
      LEFT JOIN repis.kirjed k ON k.kirjekood = d.kirjekood
      LEFT JOIN repis.desktop d2 ON d2.kirjekood = d.persoon
      WHERE k.kirjekood IS NULL
      AND d.persoon != d.kirjekood
      AND d.created_by = user();


      -- Update changed silts'n'lipiks
      DELETE kl FROM repis.v_kirjelipikud kl
      RIGHT JOIN repis.desktop d ON d.kirjekood = kl.kirjekood
      WHERE d.created_by = user();
      --
      DELETE ks FROM repis.v_kirjesildid ks
      RIGHT JOIN repis.desktop d ON d.kirjekood = ks.kirjekood
      WHERE d.created_by = user();
      --
      INSERT INTO repis.v_kirjelipikud (kirjekood, lipik)
      SELECT d.kirjekood, dl.lipik
      FROM repis.desk_lipikud dl
      RIGHT JOIN repis.desktop d ON d.id = dl.desktop_id
      WHERE d.created_by = user()
        AND dl.lipik IS NOT NULL;
      --
      INSERT INTO repis.v_kirjesildid (kirjekood, silt)
      SELECT d.kirjekood, dl.silt
      FROM repis.desk_sildid dl
      RIGHT JOIN repis.desktop d ON d.id = dl.desktop_id
      WHERE d.created_by = user()
        AND dl.silt IS NOT NULL;


      -- Update changed persons
      UPDATE repis.kirjed k
      RIGHT JOIN repis.desktop d ON d.kirjekood = k.kirjekood
      LEFT JOIN repis.desktop d2 ON d2.kirjekood = d.persoon
      SET k.persoon = d.persoon,
          k.lipikud = repis.func_kirjelipikud(k.kirjekood),
          k.sildid = repis.func_kirjesildid(k.kirjekood),
          k.kirje = d.kirje, k.legend = d.legend,
          k.perenimi = d.perenimi, k.eesnimi = d.eesnimi,
          k.isanimi = d.isanimi, k.emanimi = d.emanimi,
          k.sünd = d.sünd, k.surm = d.surm, k.allikas = d.allikas,
          k.matmisaeg = d.matmisaeg, k.sünnikoht = d.sünnikoht, 
          k.elukoht = d.elukoht, k.matmiskoht = d.matmiskoht, 
          k.`surma põhjus` = d.`surma põhjus`,
          k.välisviide = d.välisviide, k.EkslikKanne = d.EkslikKanne,
          k.Peatatud = d.Peatatud,
          k.EiArvesta = d.EiArvesta,
          k.updated_at = now(), updated_by = SUBSTRING_INDEX(user(), '@', 1),
          k.KirjePersoon = if(d.allikas IN ('EMI', 'TS'),
               repis.desktop_person_text(
                 d2.perenimi, d2.eesnimi,
                 d2.isanimi, d2.emanimi,
                 d2.sünd, d2.surm
               ),
               NULL
            ),
          k.kirjeJutt = if(d.allikas IN ('EMI', 'TS'), d.jutt, NULL)
      WHERE d.created_by = user();


      -- Remove deleted records
      UPDATE repis.kirjed k
      RIGHT JOIN repis.desktop d ON d.kirjekood = k.kirjekood
                                AND d.created_by = user()
                                AND d.Kustuta = '!'
      SET k.persoon = NULL;

      DELETE k FROM repis.kirjed k
      RIGHT JOIN repis.desktop d ON d.kirjekood = k.kirjekood
                                AND d.created_by = user()
                                AND d.Kustuta = '!';

      -- Clean desktop
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,            params, created_by)
      VALUES                           (NULL,        NULL,       'desktop_flush', NULL,   user());
    END IF;

  END;;

DELIMITER ;
