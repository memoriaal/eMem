SELECT now();
/* rights
  6s x 2 */
 INSERT INTO aruanded.props (entity, TYPE, datatype, value_reference, created_at, created_by)
   SELECT
      entity,
      '_owner',
      'reference',
      '3',
      now(),
      4
   FROM aruanded.props
   WHERE TYPE = '_mid';
 INSERT INTO aruanded.props (entity, TYPE, datatype, value_reference, created_at, created_by)
   SELECT
      entity,
      '_owner',
      'reference',
      '4',
      now(),
      4
   FROM aruanded.props
   WHERE TYPE = '_mid';
