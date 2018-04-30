DELIMITER ;;

CREATE OR REPLACE TRIGGER repis.vorm_emi_BI BEFORE INSERT ON repis.vorm_uus_emi FOR EACH ROW
proc_label:BEGIN

  SELECT lpad(max(right(kirjekood, 6))+1, 10, 'EMI-000000') INTO @ik
    FROM repis.kirjed where allikas = 'EMI';

  SET NEW.id = @ik;
  -- SET NEW.allikas = 'EMI';
END;;

DELIMITER ;


DELIMITER ;;

CREATE OR REPLACE TRIGGER repis.vorm_emi_BU BEFORE UPDATE ON repis.vorm_uus_emi FOR EACH ROW
proc_label:BEGIN

  SET NEW.kirje =
    concat_ws('. ',
      concat_ws(', ',
        if(NEW.perenimi = '', NULL, NEW.perenimi),
        if(NEW.eesnimi = '', NULL, NEW.eesnimi),
        if(NEW.isanimi = '', NULL, NEW.isanimi),
        if(NEW.emanimi = '', NULL, concat('ema eesnimi ', NEW.emanimi))
      ),
      if(NEW.sünd = '', NULL, concat('Sünd ', NEW.sünd)),
      if(NEW.surm = '', NULL, concat('Surm ', NEW.surm)),
      if(NEW.jutt = '', NULL, NEW.jutt)
    )
  ;
  IF NEW.valmis = 1 THEN
    -- move the record to repis.kirjed
    LEAVE proc_label;
  END IF;

END;;

DELIMITER ;
