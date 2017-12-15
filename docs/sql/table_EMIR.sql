CREATE TABLE `EMIR` (
  `id` int(11) unsigned      NOT NULL AUTO_INCREMENT,
  `Perenimi` varchar(100)    NOT NULL DEFAULT '',
  `EmiPerenimi` varchar(100)          DEFAULT NULL,
  `Eesnimi` varchar(100)     NOT NULL DEFAULT '',
  `EmiEesnimi` varchar(100)           DEFAULT NULL,
  `Isanimi` varchar(100)     NOT NULL DEFAULT '',
  `EmiIsanimi` varchar(100)           DEFAULT NULL,
  `Sünd` varchar(100)        NOT NULL DEFAULT '',
  `EmiSünd` varchar(10)               DEFAULT NULL,
  `Surm` varchar(100)        NOT NULL DEFAULT '',
  `EmiSurm` varchar(10)               DEFAULT NULL,
  `Kommentaar` varchar(100)  NOT NULL DEFAULT '',
  `Kirjed` text                       DEFAULT NULL,
  `ref` int(11) unsigned              DEFAULT NULL,
  `user` varchar(50)         NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;