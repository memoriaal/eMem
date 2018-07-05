SELECT now();
/* entity id
   3s */
INSERT INTO aruanded.props (entity, type, datatype, value_text, created_at, created_by)
   SELECT
      if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', persoon)),
      '_mid',
      'string',
      if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', persoon)),
      created_at,
      '4'
   FROM repis.kirjed
   WHERE allikas = 'Persoon';

/* entity type
   3s */
INSERT INTO aruanded.props (entity, type, datatype, value_text, created_at, created_by)
   SELECT
      if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', persoon)),
      '_type',
      'string',
      'r_persoon',
      created_at,
      '4'
   FROM repis.kirjed
   WHERE allikas = 'Persoon';

/* entity name formula
   3s */
INSERT INTO aruanded.props (entity, type, datatype, search, language, value_text)
   SELECT
      if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', persoon)),
      'name' AS property_definition,
      'formula' AS property_type,
      1 AS search,
      NULL property_language,
      '@eesnimi@ @perenimi@' AS value_text
   FROM repis.kirjed
   WHERE allikas = 'Persoon';

/* entity created at/by
   3 sec */
INSERT INTO aruanded.props (entity, type, datatype, created_at, created_by)
   SELECT
      if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', persoon)),
      '_created',
      'atby',
      created_at,
      '4'
   FROM repis.kirjed
   WHERE allikas = 'Persoon';
