CREATE DEFINER=`michelek`@`127.0.0.1` FUNCTION repis.`kirje_std_persoon`(
    `_perenimi` VARCHAR(50),
    `_eesnimi` VARCHAR(50),
    `_isanimi` VARCHAR(50),
    `_emanimi` VARCHAR(50),
    `_sünd` VARCHAR(50),
    `_surm` VARCHAR(50)
  )
  RETURNS varchar(2000) CHARSET utf8 COLLATE utf8_estonian_ci
  LANGUAGE SQL
  NOT DETERMINISTIC
  NO SQL
  SQL SECURITY DEFINER
  COMMENT ''
  BEGIN
      RETURN concat_ws('. ',
        concat_ws(', ',
          if(_perenimi = '', NULL, _perenimi),
          if(_eesnimi  = '', NULL, _eesnimi),
          if(_isanimi  = '', NULL, concat('isa ', _isanimi)),
          if(_emanimi  = '', NULL, concat('ema ', _emanimi))
        ),
        if(_sünd       = '', NULL, concat('Sünd ', _sünd)),
        if(_surm       = '', NULL, concat('Surm ', _surm))
      );
  END


CREATE DEFINER=`michelek`@`127.0.0.1` FUNCTION import.`kirje_PR`(
    `_kirjekood` CHAR(10)
  )
  RETURNS varchar(2000) CHARSET utf8 COLLATE utf8_estonian_ci
  LANGUAGE SQL
  NOT DETERMINISTIC
  CONTAINS SQL
  SQL SECURITY DEFINER
  COMMENT ''
  func_label:BEGIN

    SELECT concat_ws('. ',
      concat_ws(', ',
        concat_ws(';',
          if(pr.isik_perenimi='',NULL,pr.isik_perenimi),
          if(pr.isik_perenimi_endine1='',NULL,pr.isik_perenimi_endine1),
          if(pr.isik_perenimi_endine2='',NULL,pr.isik_perenimi_endine2),
          if(pr.isik_perenimi_endine3='',NULL,pr.isik_perenimi_endine3),
          if(pr.isik_perenimi_endine4='',NULL,pr.isik_perenimi_endine4)
        ),
        concat_ws(';',
          if(pr.isik_eesnimi='',NULL,pr.isik_eesnimi),
          if(pr.isik_eesnimi_endine1='',NULL,pr.isik_eesnimi_endine1),
          if(pr.isik_eesnimi_endine2='',NULL,pr.isik_eesnimi_endine2)
        )
      ),
      concat_ws(', ',
        if(pr.sünd='',NULL,concat('Sünd: ', pr.sünd)),
        if(pr.isik_synnikoht='',NULL,repis.func_rr_aadress(pr.isik_synnikoht))
      ),
      if(pr.surm='' AND pr.isik_surmakoht='', NULL,
        concat_ws(', ',
          if(pr.surm='',NULL,concat('Surm: ', pr.surm)),
          if(pr.isik_surmakoht='',NULL,repis.func_rr_aadress(pr.isik_surmakoht))
        )
      ),
      if(pr.isa_eesnimi='',NULL,concat('Isa ', CONCAT_WS(' ', pr.isa_eesnimi, pr.isa_synniaasta))),
      if(pr.ema_eesnimi='',NULL,concat('Ema ', CONCAT_WS(' ', pr.ema_eesnimi, pr.ema_synniaasta))),
      CONCAT('[',pr.raamatu_omavalitsus,' kd',pr.koite_nr,' lk',pr.lk_nr,']')
    ) INTO @_kirje
    from import.pereregister pr
    WHERE pr.isikukood = _kirjekood COLLATE utf8_estonian_ci;

    RETURN @_kirje;

  END
  

CREATE DEFINER=`michelek`@`127.0.0.1` FUNCTION `kirje_RK`(
    `_kirjekood` CHAR(10)
  )
  RETURNS varchar(2000) CHARSET utf8 COLLATE utf8_estonian_ci
  LANGUAGE SQL
  NOT DETERMINISTIC
  CONTAINS SQL
  SQL SECURITY DEFINER
  COMMENT ''
  func_label:BEGIN

    SELECT CASE WHEN rk.Sünniaeg = '' THEN rk.SA ELSE rk.Sünniaeg END INTO @_sünd
    FROM import.repr_kart rk
    WHERE rk.isikukood = _kirjekood COLLATE utf8_estonian_ci;

    SELECT repis.kirje_std_persoon(
      rk.PERENIMI, rk.EESNIMI, rk.ISANIMI, rk.EMANIMI,
      @_sünd, rk.Surm
    ) INTO @_kirje
    FROM import.repr_kart rk
    WHERE rk.isikukood = _kirjekood COLLATE utf8_estonian_ci;

    RETURN @_kirje;

  END


CREATE DEFINER=`michelek`@`127.0.0.1` FUNCTION `kirje_RPT`(
    `_kirjekood` CHAR(10)
  )
  RETURNS varchar(2000) CHARSET utf8 COLLATE utf8_estonian_ci
  LANGUAGE SQL
  NOT DETERMINISTIC
  CONTAINS SQL
  SQL SECURITY DEFINER
  COMMENT ''
  func_label:BEGIN

    SELECT concat_ws('. ',
      concat_ws(', ',
        concat_ws(';',
          if(pt.perenimi='',NULL,pt.perenimi),
          if(pt.muuperenimi='',NULL,pt.muuperenimi)
        ),
        concat_ws(';',
          if(pt.eesnimi='',NULL,pt.eesnimi),
          if(pt.muueesnimi='',NULL,pt.muueesnimi)
        )
      ),
      concat_ws(', ',
        if(pt.sünd='',NULL,concat('Sünd: ', pt.sünd)),
        if(pt.synnikoht='',NULL,repis.func_rr_aadress(pt.synnikoht))
      ),
      if(pt.surm='' AND pt.surmakoht='', NULL,
        concat_ws(', ',
          if(pt.surm='',NULL,concat('Surm: ', pt.surm)),
          if(pt.surmakoht='',NULL,repis.func_rr_aadress(pt.surmakoht))
        )
      ),
      pt.paragrahv,
      if(pt.isaeesnimi='',NULL,concat('Isa ', CONCAT_WS(' ', pt.isaeesnimi, pt.isaperenimi))),
      if(pt.emaeesnimi='',NULL,concat('Ema ', CONCAT_WS(' ', pt.emaeesnimi, pt.emaperenimi))),
      CONCAT('[',pt.toimik,']')
    ) INTO @_kirje
    from import.pensionitoimikud pt
    WHERE pt.kirjekood = _kirjekood COLLATE utf8_estonian_ci;

    RETURN @_kirje;

  END


CREATE DEFINER=`michelek`@`127.0.0.1` PROCEDURE `import_PR`(
    IN `_persoon` CHAR(10),
    IN `_kirjekood` CHAR(10)
  )
  LANGUAGE SQL
  NOT DETERMINISTIC
  CONTAINS SQL
  SQL SECURITY DEFINER
  COMMENT ''
  proc_label:BEGIN

    SELECT import.kirje_PR(_kirjekood) INTO @_kirje;

    INSERT INTO repis.kirjed (persoon, kirjekood, Kirje, 
            Perenimi, Eesnimi, Isanimi, Emanimi,
            Sünd, Surm, Allikas, legend,
            KirjePersoon,
            EesnimiC, PerenimiC, IsanimiC)
    SELECT _persoon, _kirjekood, @_kirje,
            ifnull(pr.isik_perenimi, ''), ifnull(pr.isik_EESNIMI, ''), ifnull(pr.isa_eesnimi, ''), ifnull(pr.ema_eesnimi, ''),
            pr.Sünd, pr.Surm, 'RPT', NULL,
            @_kirje_persoon,
            ifnull(repis.func_unrepeat(upper(pr.isik_EESNIMI)), ''),
            ifnull(repis.func_unrepeat(upper(pr.isik_perenimi)), ''),
            ifnull(repis.func_unrepeat(upper(pr.isa_eesnimi)), '')
    FROM import.pereregister pr
    WHERE pr.isikukood = _kirjekood;

  END


CREATE DEFINER=`michelek`@`127.0.0.1` TRIGGER `import_PR_AU` AFTER UPDATE ON `pereregister` FOR EACH ROW BEGIN
	if NEW.persoon <> IFNULL(OLD.persoon, 'NULL')
	then
  		CALL import.import_PR(NEW.persoon, NEW.isikukood);
  	END if;
END


CREATE DEFINER=`michelek`@`127.0.0.1` PROCEDURE `import_RK`(
    IN `_persoon` CHAR(10),
    IN `_kirjekood` CHAR(10)
  )
  LANGUAGE SQL
  NOT DETERMINISTIC
  CONTAINS SQL
  SQL SECURITY DEFINER
  COMMENT ''
  proc_label:BEGIN

    SELECT repis.kirje_RK(_kirjekood) INTO @_kirje;

    INSERT INTO repis.kirjed (persoon, kirjekood, Kirje, 
              Perenimi, Eesnimi, Isanimi, Emanimi,
              Sünd, Surm, Allikas, legend,
              KirjePersoon)
    SELECT _persoon, _kirjekood, @_kirje,
              ifnull(rk.PERENIMI, ''), ifnull(rk.EESNIMI, ''), ifnull(rk.ISANIMI, ''), ifnull(rk.EMANIMI, ''),
              CASE WHEN length(rk.Sünniaeg) = 0 THEN rk.SA ELSE rk.Sünniaeg END, 
              rk.Surm, 'RK', rk.otmetki,
              @_kirje
    FROM import.repr_kart rk
    WHERE rk.isikukood = _kirjekood;

  END


CREATE DEFINER=`michelek`@`127.0.0.1` TRIGGER `import_RK_AU` AFTER UPDATE ON `repr_kart` FOR EACH ROW BEGIN
	if NEW.persoon <> IFNULL(OLD.persoon, 'NULL')
	then
  		CALL import.import_PR(NEW.persoon, NEW.isikukood);
  	END if;
END


CREATE DEFINER=`michelek`@`127.0.0.1` PROCEDURE `import_RPT`(
    IN `_persoon` CHAR(10),
    IN `_kirjekood` CHAR(10)
  )
  LANGUAGE SQL
  NOT DETERMINISTIC
  CONTAINS SQL
  SQL SECURITY DEFINER
  COMMENT ''
  proc_label:BEGIN

    SELECT import.kirje_RPT(_kirjekood) INTO @_kirje;

    INSERT INTO repis.kirjed (persoon, kirjekood, Kirje, 
            Perenimi, Eesnimi, Isanimi, Emanimi,
            Sünd, Surm, Allikas, legend,
            KirjePersoon,
            EesnimiC, PerenimiC, IsanimiC)
    SELECT _persoon, _kirjekood, @_kirje,
            ifnull(pt.PERENIMI, ''), ifnull(pt.EESNIMI, ''), ifnull(pt.ISANIMI, ''), ifnull(pt.EMANIMI, ''),
            pt.Sünd, pt.Surm, 'RPT', NULL,
            @_kirje_persoon,
            ifnull(repis.func_unrepeat(upper(pt.EESNIMI)), ''),
            ifnull(repis.func_unrepeat(upper(pt.PERENIMI)), ''),
            ifnull(repis.func_unrepeat(upper(pt.ISANIMI)), '')
    FROM import.pensionitoimikud pt
    WHERE pt.kirjekood = _kirjekood;
  END


CREATE DEFINER=`michelek`@`127.0.0.1` TRIGGER `import_RPT_AU` AFTER UPDATE ON `pensionitoimikud` FOR EACH ROW BEGIN
	if NEW.persoon <> IFNULL(OLD.persoon, 'NULL')
	then
  		CALL import.import_PR(NEW.persoon, NEW.kirjekood);
  	END if;
END