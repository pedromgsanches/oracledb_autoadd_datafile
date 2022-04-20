--- Create auxiliary tables


create table dba_ops.operationsconfig (
operation varchar2(32) not null,
obs varchar2(512),
par1 varchar2(32),
par2 varchar2(32));
ALTER TABLE dba_ops.OPERATIONSCONFIG ADD CONSTRAINT OPERATIONSCONFIG_PK PRIMARY KEY (  OPERATION ) ENABLE;
insert into dba_ops.operationsconfig (operation, obs, par1, par2) values ('pr_add_datafile','procedimento add datafile, TRESHOLD alem de PAR2 datafiles em PAR1 minutos',120,3);
commit;


create table dba_ops.operationslog (
op_id number,
operation varchar2(32),
object_name varchar2(64),
op_text varchar2(2048),
op_date date);

CREATE SEQUENCE dba_ops.SEQ_OPERATIONSLOG INCREMENT BY 1 START WITH 1 MAXVALUE 9999999999999 CYCLE NOCACHE;
---0(p_xconn_key IN NUMBER, cleaning_thread in number, p_thread_id in number);


create or replace trigger dba_ops.tr_operations  
    before insert on dba_ops."OPERATIONSLOG"
    for each row
begin
    select SEQ_OPERATIONSLOG.nextval into :NEW."OP_ID" from dual;
    select sysdate into :NEW."OP_DATE" from dual;
end;