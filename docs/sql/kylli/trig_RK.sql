DELIMITER ;;

CREATE OR REPLACE TRIGGER repr_kart_BU BEFORE UPDATE ON repr_kart FOR EACH ROW
BEGIN
  IF NEW.seos = '+' THEN
    INSERT IGNORE INTO z_queue (isikukood1, task, user)
    VALUES (NEW.isikukood, 'Import from RK', 'kirjed_BU');
    SET NEW.seos = '';
  END IF;
END;;



CREATE OR REPLACE TRIGGER repr_kart_AU AFTER UPDATE ON repr_kart FOR EACH ROW
BEGIN

  INSERT INTO `repr_kart_audit_log` 
     (
`id`, `seos`, `Kat`, `PERENIMI`, `EESNIMI`, `SA`, `otmetki`, `Surm`, `F`, `I`, `O`, `SUGU`, `sünniriik`, `NSV, ANSV, oblast, krai, kubermang, kond`, `sünnilinn, vald, rajoon`, `muu`, `riik`, `NSV, ANSV, oblast, krai, kubermang, maakond`, `eluk. linn, vald, rajoon`, `alev, küla, tänav, maja, talu, korter, muu`, `sots staatus`, `prof spets`, `töökoht`, `part`, `nac`, `rahvus`, `Arreteerimiskuupäev`, `Deporteerimiskuupäev`, `küüditamise alus`, `st st uk, §§`, `kartochka zapolnena`, `Täitmise kuupäev`, `organ`, `otdel`, `31`, `№№ del sl`, `Muude toimikute nr-d`, `Sõrmejälg`, `Läbikriipsutamine`, `Templid dakt`, `Kp. tempel`, `Кем осужден / küüditamisotsuse tegija`, `Kohtuistung`, `Süüdimõistmise kuupäev`, `§§`, `Cт ст УК §§ 34`, `7_34`, `17-58-1a`, `19-58-1b`, `58-1a`, `58-1b`, `58-2`, `58-3`, `58-4`, `58-6`, `58-8`, `58-9`, `58-10/     lg 1 või 1`, `58-11`, `58-12`, `58-13`, `59-2`, `60, lg 2`, `182, lg0`, `193-17а`, `145 ч.2`, `Muud §§`, `Esialgne karistus`, `Срок,  režiim`, `Lõplik karistus (kui erineb esialgsest)`, `ПП`, `КИ / БК`, `dopolnitelnije meri`, `Märkus küüditamise kohta`, `nachalo sroka`, `Hukkamisele viidud`, `Hukkamiskoht/surmakoht`, `Hukkaja organ`, `Vabanemiskuupäev`, `Asumiselt vabastatud`, `Rehabiliteerimiskuupäev`, `Vorm`, `Märkused1`, `Sisestaja`, `Allikas`, `Jrk nr`, `85`, `Nr`, `Probleemid`, `Mementol olemas?`, `Märkused2`, `Arreteerimise tunnus`, `Küüditamise tunnus`, `Muu represseerimise tunnus`, `Represseerimiseaeg`, `Naasmise tunnus`, `Naasmise aeg`, `Dokumendiliik`, `IJRK`, `K-Kausta number`, `Aadress küüditamise ajal`, `K Lehekülje number`, `K Number`, `Otsus küüditamise kohta`, `Otsuse kuupäev`, `Küüditamise koht 3`, `Arr Kausta number`, `Lehekülg`, `Number`, `Aadress arreteerimise ajal`, `Mitu aastat asumisel`, `Kinnipidamiskoht1`, `Kinnipidamiskoht2`, `Kinnipidamiskoht3`, `Arreteeritu naasmise tunnus`, `Arreteerimisdokumendi liik`, `Sünniaeg`,      
      `created`, `updated`, `user`)
  VALUES
	(
NEW.`id`, NEW.`seos`, NEW.`Kat`, NEW.`PERENIMI`, NEW.`EESNIMI`, NEW.`SA`, NEW.`otmetki`, NEW.`Surm`, NEW.`F`, NEW.`I`, NEW.`O`, NEW.`SUGU`, NEW.`sünniriik`, NEW.`NSV, ANSV, oblast, krai, kubermang, kond`, NEW.`sünnilinn, vald, rajoon`, NEW.`muu`, NEW.`riik`, NEW.`NSV, ANSV, oblast, krai, kubermang, maakond`, NEW.`eluk. linn, vald, rajoon`, NEW.`alev, küla, tänav, maja, talu, korter, muu`, NEW.`sots staatus`, NEW.`prof spets`, NEW.`töökoht`, NEW.`part`, NEW.`nac`, NEW.`rahvus`, NEW.`Arreteerimiskuupäev`, NEW.`Deporteerimiskuupäev`, NEW.`küüditamise alus`, NEW.`st st uk, §§`, NEW.`kartochka zapolnena`, NEW.`Täitmise kuupäev`, NEW.`organ`, NEW.`otdel`, NEW.`31`, NEW.`№№ del sl`, NEW.`Muude toimikute nr-d`, NEW.`Sõrmejälg`, NEW.`Läbikriipsutamine`, NEW.`Templid dakt`, NEW.`Kp. tempel`, NEW.`Кем осужден / küüditamisotsuse tegija`, NEW.`Kohtuistung`, NEW.`Süüdimõistmise kuupäev`, NEW.`§§`, NEW.`Cт ст УК §§ 34`, NEW.`7_34`, NEW.`17-58-1a`, NEW.`19-58-1b`, NEW.`58-1a`, NEW.`58-1b`, NEW.`58-2`, NEW.`58-3`, NEW.`58-4`, NEW.`58-6`, NEW.`58-8`, NEW.`58-9`, NEW.`58-10/     lg 1 või 1`, NEW.`58-11`, NEW.`58-12`, NEW.`58-13`, NEW.`59-2`, NEW.`60, lg 2`, NEW.`182, lg0`, NEW.`193-17а`, NEW.`145 ч.2`, NEW.`Muud §§`, NEW.`Esialgne karistus`, NEW.`Срок,  režiim`, NEW.`Lõplik karistus (kui erineb esialgsest)`, NEW.`ПП`, NEW.`КИ / БК`, NEW.`dopolnitelnije meri`, NEW.`Märkus küüditamise kohta`, NEW.`nachalo sroka`, NEW.`Hukkamisele viidud`, NEW.`Hukkamiskoht/surmakoht`, NEW.`Hukkaja organ`, NEW.`Vabanemiskuupäev`, NEW.`Asumiselt vabastatud`, NEW.`Rehabiliteerimiskuupäev`, NEW.`Vorm`, NEW.`Märkused1`, NEW.`Sisestaja`, NEW.`Allikas`, NEW.`Jrk nr`, NEW.`85`, NEW.`Nr`, NEW.`Probleemid`, NEW.`Mementol olemas?`, NEW.`Märkused2`, NEW.`Arreteerimise tunnus`, NEW.`Küüditamise tunnus`, NEW.`Muu represseerimise tunnus`, NEW.`Represseerimiseaeg`, NEW.`Naasmise tunnus`, NEW.`Naasmise aeg`, NEW.`Dokumendiliik`, NEW.`IJRK`, NEW.`K-Kausta number`, NEW.`Aadress küüditamise ajal`, NEW.`K Lehekülje number`, NEW.`K Number`, NEW.`Otsus küüditamise kohta`, NEW.`Otsuse kuupäev`, NEW.`Küüditamise koht 3`, NEW.`Arr Kausta number`, NEW.`Lehekülg`, NEW.`Number`, NEW.`Aadress arreteerimise ajal`, NEW.`Mitu aastat asumisel`, NEW.`Kinnipidamiskoht1`, NEW.`Kinnipidamiskoht2`, NEW.`Kinnipidamiskoht3`, NEW.`Arreteeritu naasmise tunnus`, NEW.`Arreteerimisdokumendi liik`, NEW.`Sünniaeg`, 	
	 NEW.`created`, NEW.`updated`, NEW.`user`);


  IF NEW.seos IS NOT NULL AND OLD.seos IS NULL THEN
    INSERT IGNORE INTO z_queue (isikukood1, task, user)
    VALUES (NEW.isikukood, 'Import from RK', 'kirjed_BU');
  END IF;

END;;

DELIMITER ;
