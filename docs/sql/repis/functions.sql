
DELIMITER ;; -- func_kirje_lipikud

  CREATE OR REPLACE DEFINER=queue@localhost FUNCTION repis.func_kirje_lipikud(
        _kirjekood CHAR(10)
    ) RETURNS VARCHAR(2000) CHARSET utf8 COLLATE utf8_estonian_ci

    func_label:BEGIN

      SELECT persoon INTO @persoon FROM repis.kirjed WHERE kirjekood = _kirjekood;

      SELECT group_concat(v.lipik, ' [', v.created_by , '@', v.created_at, ']' SEPARATOR ' \n') INTO @pre
      FROM repis.v_kirjelipikud v
      WHERE v.kirjekood = @kirjekood
      AND v.deleted_at = '0000-00-00 00:00:00'
      ;

      SELECT group_concat(v.kirjekood, ':', v.lipik, ' [', v.created_by , '@', v.created_at, ']' SEPARATOR ' \n') INTO @post
      FROM repis.v_kirjelipikud v
      RIGHT JOIN repis.kirjed k ON k.kirjekood = v.kirjekood
      WHERE k.persoon = @persoon
      AND v.kirjekood IS NOT NULL
      AND k.kirjekood != @kirjekood
      AND v.deleted_at = '0000-00-00 00:00:00'
      ;

      RETURN concat_ws('',
        concat(@pre, '\n'),
        '---',
        concat('\n', @post)
      ) COLLATE utf8_estonian_ci;

    END;;

DELIMITER ;
