CREATE OR REPLACE view web_export
AS
    select k.emi_id
    , SUBSTRING_INDEX( SUBSTRING_INDEX( group_concat(
        if(k.perenimi = ''   OR a.prioriteetPerenimi = 0, NULL, UPPER(k.perenimi)) 
        ORDER BY a.prioriteetPerenimi DESC SEPARATOR ';'), ';', 1), ';', -1)
        AS perenimi
    , SUBSTRING_INDEX( SUBSTRING_INDEX( group_concat(
        if(k.eesnimi = ''    OR a.prioriteetEesnimi  = 0,  NULL, REPLACE(UPPER(k.eesnimi),'ALEKSANDR','ALEKSANDER')) 
        ORDER BY a.prioriteetEesnimi  DESC SEPARATOR ';'), ';', 1), ';', -1)
        AS eesnimi
    , SUBSTRING_INDEX( SUBSTRING_INDEX( group_concat(
        if(k.isanimi = ''    OR a.prioriteetIsanimi  = 0,  NULL, UPPER(k.isanimi))
        ORDER BY a.prioriteetIsanimi  DESC SEPARATOR ';'), ';', 1), ';', -1)
        AS isanimi
    , SUBSTRING_INDEX( SUBSTRING_INDEX( group_concat(
        if(k.sünd = ''       OR a.prioriteetSünd     = 0,  NULL, LEFT(k.sünd,4)) 
        ORDER BY a.prioriteetSünd     DESC SEPARATOR ';'), ';', 1), ';', -1)
        AS sünd
    , SUBSTRING_INDEX( SUBSTRING_INDEX( group_concat(
        if(k.surm = ''       OR a.prioriteetSurm     = 0,  NULL, LEFT(k.surm,4)) 
        ORDER BY a.prioriteetSurm     DESC SEPARATOR ';'), ';', 1), ';', -1)
        AS surm

    , k.kivi
    
    , replace(group_concat( DISTINCT
        if( a.prioriteetKirje = 0,
            NULL, 
            concat(k.kirje, ' [', k.isikukood, '|', a.nimetus, ']')
        )
        ORDER BY a.prioriteetKirje    DESC SEPARATOR ';\n'), '"', "'")
        AS kirjed

    , replace(group_concat(if(kp.isikukood IS NULL, NULL, concat_ws(' ', kp.isikukood, kp.kirje)) 
        ORDER BY kp.isikukood SEPARATOR ';\n'), '"', "'")
        AS pereseos

    from kirjed k
    left join allikad a on a.kood = k.allikas
    left join kirjed kp on kp.perekood != '' and kp.perekood = k.perekood
    where k.EkslikKanne = ''
    and k.Puudulik = ''
    and k.Peatatud = ''
    group by k.emi_id
;
