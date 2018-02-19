DELIMITER ;;

CREATE OR REPLACE PROCEDURE import_from_pereregister(IN _ik1 CHAR(10), IN _ik2 CHAR(10), IN _user VARCHAR(50))
BEGIN

    INSERT IGNORE INTO kirjed SET isikukood = _ik1, allikas = 'PR';

    SELECT concat_ws('. ',
      concat_ws(', ',
        concat_ws(';',
          if(isik_perenimi='',NULL,isik_perenimi),
          if(isik_perenimi_endine1='',NULL,isik_perenimi_endine1),
          if(isik_perenimi_endine2='',NULL,isik_perenimi_endine2),
          if(isik_perenimi_endine3='',NULL,isik_perenimi_endine3),
          if(isik_perenimi_endine4='',NULL,isik_perenimi_endine4)
        ),
        concat_ws(';',
          if(isik_eesnimi='',NULL,isik_eesnimi),
          if(isik_eesnimi_endine1='',NULL,isik_eesnimi_endine1),
          if(isik_eesnimi_endine2='',NULL,isik_eesnimi_endine2)
        ),
        if(isa_eesnimi='',NULL,isa_eesnimi),
        if(ema_eesnimi='',NULL,concat('ema eesnimi ',ema_eesnimi)),
        if(isik_sugu='',NULL,isik_sugu)
      ),
      concat_ws(', ',
        if(isik_synniaasta='',NULL,concat('Sünd: ', concat_ws('-',
          isik_synniaasta,
          if(isik_synnikuu='',NULL,LPAD(isik_synnikuu, 2, '00')),
          if(isik_synnipaev='',NULL,LPAD(isik_synnipaev, 2, '00'))
        ))),
        if(isik_synnikoht='',NULL,isik_synnikoht),
        if(isik_synniriik='',NULL,isik_synniriik)
      ),
      if(isik_surmaaasta='' AND isik_surmakoht='' AND isik_surmariik='', NULL,
        concat_ws(', ',
          if(isik_surmaaasta='',NULL,concat('Surm: ', concat_ws('-',
            isik_surmaaasta,
            if(isik_surmakuu='',NULL,LPAD(isik_surmakuu, 2, '00')),
            if(isik_surmapaev='',NULL,LPAD(isik_surmapaev, 2, '00'))
          ))),
          if(isik_surmakoht='',NULL,isik_surmakoht),
          if(isik_surmariik='',NULL,isik_surmariik)
        )
      ),
      concat('Raamat: ', raamatu_omavalitsus, ' kd ', koite_nr, ' lk ', lk_nr),
      ''
    ) INTO @_kirje
    FROM pereregister
    WHERE isikukood = _ik1;

    UPDATE kirjed k
    LEFT JOIN pereregister pr on pr.isikukood = k.isikukood 
    SET
      k.kirje = @_kirje,
      k.perenimi = pr.isik_perenimi,
      k.eesnimi = pr.isik_eesnimi,
      k.isanimi = pr.isa_eesnimi,
      k.sünd = ifnull(concat_ws('-', 
        if(pr.isik_synniaasta = '', NULL, pr.isik_synniaasta), 
        if(pr.isik_synnikuu = '', NULL, pr.isik_synnikuu), 
        if(pr.isik_synnipaev = '', NULL, pr.isik_synnipaev)
      ), ''),
      k.surm = ifnull(concat_ws('-', 
        if(pr.isik_surmaaasta = '', NULL, pr.isik_surmaaasta), 
        if(pr.isik_surmakuu = '', NULL, pr.isik_surmakuu), 
        if(pr.isik_surmapaev = '', NULL, pr.isik_surmapaev)
      ), '')
    WHERE pr.isikukood = _ik1;
    
    IF _ik2 IS NOT NULL THEN
      INSERT INTO z_queue (isikukood1, isikukood2, task, params, user)
      VALUES (_ik2, _ik1, 'create connections', '', _user);
    END IF;

END;;
DELIMITER ;


