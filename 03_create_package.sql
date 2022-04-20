---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
create or replace package dba_ops.pk_operations as
procedure pr_logaction(v_operation in varchar2,v_object in varchar2, v_op_text in varchar2);
procedure pr_add_datafile;
end;
---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------


create or replace package body dba_ops.pk_operations is
procedure pr_logaction (v_operation in varchar2,v_object in varchar2, v_op_text in varchar2) is
        /* procedimento para escrever o log*/
        begin
        insert into dba_ops.operationslog (operation,object_name,op_text) values (v_operation,v_object,v_op_text);
        end;

procedure pr_add_datafile is
            /* apenas se livre abaixo de 25% e menos de 31gb livres, pq pode ter 1tb livre e ser inferior a 25%  */
    cursor c_datafiles_ocup is select * from dba_ops.tablespaces_v2 where "LivrePercentagem"<25 and "LivreMB"<31744
								and "TABLESPACE" not in (select tablespace_name from dba_tablespaces where contents='TEMPORARY');
    datafiles_ocup c_datafiles_ocup%rowtype;
    v_text varchar2(256);
    v_par1 number;
    v_par2 number;
    v_countops number;

begin
    select par1 into v_par1 from dba_ops.operationsconfig where operation='pr_add_datafile';
    select par2 into v_par2 from dba_ops.operationsconfig where operation='pr_add_datafile';
    open c_datafiles_ocup;
        LOOP
        fetch c_datafiles_ocup into datafiles_ocup;
        EXIT WHEN c_datafiles_ocup%NOTFOUND;

            /* ALTERNATIVA--PREENCHER V_COUNTOPS com OPERATIONSLOG
            select count(1) into v_countops from dba_ops.operationslog
            where object_name=datafiles_ocup."TABLESPACE"
            and op_date>sysdate-v_par1/60/24;  */
            select /*+ parallel v$datafile 4 */ count(1) into v_countops 
            from v$datafile
            where 
            creation_time>sysdate-v_par1/60/24 and 
            TS#=(select TS# from v$tablespace where name=datafiles_ocup."TABLESPACE");

            if v_countops <= v_par2 then
                begin
                /* size=16m, autoextend 1g, maxsize unlimited, destino do ficheiro no parametro db_create_file_dest */
                v_text:='alter tablespace ' || datafiles_ocup."TABLESPACE" || ' add datafile size 16m autoextend on next 1g maxsize unlimited';
                execute immediate v_text; --- comentar para efeitos de testes, apenas output para log
                pr_logaction('pr_add_datafile',datafiles_ocup."TABLESPACE",v_text);
                end;
			else pr_logaction('pr_add_datafile',datafiles_ocup."TABLESPACE",'TRESHOLD | PAR1 + PAR2');
            end if;
        END LOOP;
        close c_datafiles_ocup;
    end;
    
--------------------------------------------------------------------------------------------------------------------------------------------------- 
    
procedure pr_add_part_tstamp(xowner in VARCHAR2, xtable  in VARCHAR2, xcadence in VARCHAR2, xsupply in number) as

xaddpar varchar2(500);
xcount number;

BEGIN
---- add partition, range, timestamp. par1=owner,par2=table,par3=cadencia(D/W/M),par4=supply_N_parts

dbms_output.put_line(xtable ||'.'|| xowner || ' - ' || xcadence || ' supply' || xsupply);

-----------------------------------------------------------------------------------------------------------------------------IF D
if xcadence='D' then
    dbms_output.put_line(xcadence || ' diario' || xsupply);
    xcount:=0;
    while  xcount<=xsupply loop 
        xaddpar:='ALTER TABLE '|| xowner ||'.'|| xtable || ' ADD PARTITION ' || SUBSTR(xtable,0,20) || '_' || to_char(sysdate+xcount,'YYYYMMDD') || ' VALUES LESS THAN (TIMESTAMP'' ' ||  to_char(sysdate+xcount+1,'YYYY-MM-DD') || ' 00:00:00.000000000+00:00'')';
        dbms_output.put_line(xaddpar);
            begin
            pk_operations.pr_logaction('pr_add_part_tstamp',xowner||'.'||xtable,SUBSTR(xtable,0,20) || '_' || to_char(sysdate+xcount,'YYYYMMDD'));
            execute immediate xaddpar;    
            EXCEPTION WHEN OTHERS THEN pk_operations.pr_logaction('pr_add_part_tstamp',xowner||'.'||xtable,SQLCODE || '- ' || SUBSTR(SQLERRM, 1, 200));  
            end;
        xcount:=xcount+1;
    end loop;
elsif

-----------------------------------------------------------------------------------------------------------------------------IF W
xcadence='W' then
    dbms_output.put_line(xcadence || ' semanal');
elsif

-----------------------------------------------------------------------------------------------------------------------------IF M
xcadence='M' then
    dbms_output.put_line(xcadence || ' mensal');
 end if;
 
END; 
---------------------------------------------------------------------------------------------------------------------------------------------------   
end;
