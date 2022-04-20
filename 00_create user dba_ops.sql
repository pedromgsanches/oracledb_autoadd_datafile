--- Create user dba_ops

create user dba_ops;
grant select on sys.v_$datafile to dba_ops;
grant select on sys.v_$tablespace to dba_ops;
GRANT ALTER TABLESPACE TO dba_ops ;