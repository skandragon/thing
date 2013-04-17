class NaturalSort < ActiveRecord::Migration
  def up
    execute <<-FLARG
    CREATE OR REPLACE FUNCTION btrsort_nextunit(text) RETURNS text AS $$
      SELECT
        CASE WHEN $1 ~ '^[^0-9]+' THEN
          COALESCE( SUBSTR( $1, LENGTH(SUBSTRING($1 FROM '[^0-9]+'))+1 ), '' )
        ELSE
          COALESCE( SUBSTR( $1, LENGTH(SUBSTRING($1 FROM '[0-9]+'))+1 ), '' )
        END
    $$ LANGUAGE SQL
    IMMUTABLE;

    CREATE OR REPLACE FUNCTION btrsort(text) RETURNS text AS $$
      SELECT
        CASE WHEN char_length($1) > 0 THEN
          CASE WHEN $1 ~ '^[^0-9]+' THEN
            RPAD(SUBSTR(COALESCE(SUBSTRING($1 FROM '^[^0-9]+'), ''), 1, 30), 30, ' ') || btrsort(btrsort_nextunit($1))
          ELSE
            LPAD(SUBSTR(COALESCE(SUBSTRING($1 FROM '^[0-9]+'), ''), 1, 30), 30, '0') || btrsort(btrsort_nextunit($1))
          END
        ELSE
          $1
        END
      ;
    $$ LANGUAGE SQL
    IMMUTABLE;
FLARG
  end

  def down
  end
end
