
DELIMITER ;;
CREATE DEFINER=`michelek`@`localhost` PROCEDURE `topeltnimed`()
BEGIN

    set @pn=NULL, @en=NULL, @in=NULL, @sü=NULL, @su=NULL, @id=NULL;
    select * from kirjed
    where emi_id in
    (
    select id0 FROM
    (
    SELECT if(     @pn=perenimi
               AND @en=eesnimi
               AND @in=isanimi
               AND abs(@sü-sünd) < 2
               AND abs(@su-surm) < 2
               , @id, NULL) as id0
    , @id := emi_id as id1, @pn := perenimi, @en := eesnimi, @in := isanimi, @sü := sünd, @su := surm, kirjed
    from v_publish
    order by eesnimi, perenimi
    ) s1
    where id0 is not null
    union 
    select distinct id1 FROM
    (
    SELECT if(     @pn=perenimi
               AND @en=eesnimi
               AND @in=isanimi
               AND abs(@sü-sünd) < 2
               AND abs(@su-surm) < 2
               , @id, NULL) as id0
    , @id := emi_id as id1, @pn := perenimi, @en := eesnimi, @in := isanimi, @sü := sünd, @su := surm, kirjed
    from v_publish
    order by eesnimi, perenimi
    ) s2
    where id0 is not null
    )
    order by eesnimi, perenimi
    ;

END;;
DELIMITER ;
