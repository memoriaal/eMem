SELECT now();
/* properties */
INSERT INTO aruanded.props (entity, type, datatype, language, public
   , value_text, value_integer, value_decimal, value_reference, value_date
   , created_at, created_by, deleted_at, deleted_by)
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', kirjekood)), 'kirjekood', 'string', NULL, 1,
       kirjekood AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas != 'Persoon'
      AND eesnimi != ''
   UNION ALL
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', kirjekood)), 'eesnimi', 'string', NULL, 1,
       eesnimi AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas != 'Persoon'
      AND eesnimi != ''
   UNION ALL
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', kirjekood)), 'perenimi', 'string', NULL, 1,
       perenimi AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas != 'Persoon'
      AND perenimi != ''
   UNION ALL
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', kirjekood)), 'isanimi', 'string', NULL, 1,
       isanimi AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas != 'Persoon'
      AND isanimi != ''
   UNION ALL
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', kirjekood)), 'emanimi', 'string', NULL, 1,
       emanimi AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas != 'Persoon'
      AND emanimi != ''
   UNION ALL
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', kirjekood)), 'synd', 'string', NULL, 1,
       `sünd` AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas != 'Persoon'
      AND `sünd` != ''
   UNION ALL
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', kirjekood)), 'surm', 'string', NULL, 1,
       surm AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas != 'Persoon'
      AND surm != ''
   UNION ALL
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', kirjekood)), 'kirje', 'string', NULL, 1,
       kirje AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas != 'Persoon'
      AND kirje != ''
;
