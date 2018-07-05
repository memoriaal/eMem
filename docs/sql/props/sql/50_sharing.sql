SELECT now();
/* share all but definitions and owners
   340k rows 8 sec */
 INSERT INTO aruanded.props (entity, type, datatype, value_integer, created_at, created_by)
   SELECT
      entity,
      '_public',
      'boolean',
      1,
      created_at,
      created_by
   FROM aruanded.props
   WHERE TYPE = '_mid';
