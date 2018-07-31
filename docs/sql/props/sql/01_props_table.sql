SELECT now();
CREATE OR REPLACE TABLE aruanded.props (
  id int(10) unsigned NOT NULL AUTO_INCREMENT,
  entity varchar(64) DEFAULT NULL,
  type varchar(32) DEFAULT NULL,
  language varchar(2) DEFAULT NULL,
  datatype varchar(16) DEFAULT NULL,
  public int(1) UNSIGNED NOT NULL DEFAULT 1,
  public int(1) UNSIGNED NOT NULL DEFAULT 1,
  value_text text DEFAULT NULL,
  value_integer int(11) DEFAULT NULL,
  value_decimal decimal(15,4) DEFAULT NULL,
  value_reference varchar(64) DEFAULT NULL,
  value_date datetime DEFAULT NULL,
  created_at datetime DEFAULT NULL,
  created_by varchar(64) DEFAULT NULL,
  deleted_at datetime DEFAULT NULL,
  deleted_by varchar(64) DEFAULT NULL,
  PRIMARY KEY (id),
  KEY entity (entity),
  KEY type (type),
  KEY language (language),
  KEY datatype (datatype)
) ENGINE=InnoDB AUTO_INCREMENT=1000000 DEFAULT CHARSET=utf8;
