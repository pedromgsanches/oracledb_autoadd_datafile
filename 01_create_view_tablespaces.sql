--- Create View dba_ops.tablespaces for tablespace size monitoring

CREATE OR REPLACE FORCE VIEW dba_ops."TABLESPACES_V2" ("TABLESPACE", "AlocadoMB", "OcupadoMB", "LivreMB", "LivrePercentagem") AS 
  select t.tablespace_name TABLESPACE,
       ROUND(sum(t.maxbytes)/1024/1024) "AlocadoMB",
       ROUND(sum(t.bytes)/1024/1024) "OcupadoMB",
       ROUND(((sum(t.maxbytes)-sum(t.bytes))+sum(t.freebytes))/1024/1024) "LivreMB",
       ROUND(((sum(t.maxbytes)-sum(t.bytes))+sum(t.freebytes))*100/sum(t.maxbytes),2) "LivrePercentagem"
from
(
select ts.tablespace_name,
       nvl(sum(decode(df.Autoextensible,'YES',nvl(df.maxbytes,df.bytes),df.bytes)),0) maxbytes,
       nvl(sum(df.bytes),0) bytes,
       0 freebytes
from dba_tablespaces ts, dba_data_files df
where df.tablespace_name=ts.tablespace_name
group by ts.tablespace_name
UNION ALL
select fr.tablespace_name,
       0 maxbytes,
       0 bytes,
       nvl(sum(fr.bytes),0) freebytes
from dba_free_space fr
group by fr.tablespace_name
UNION ALL
SELECT ts.tablespace_name, 
       0 maxbytes,
       0 bytes,
       SUM(ts.BYTES) freebytes 
   FROM DBA_UNDO_EXTENTS ts
where ts.status='EXPIRED'
GROUP BY ts.tablespace_name
UNION ALL
select ts.tablespace_name,
       nvl(sum(decode(df.Autoextensible,'YES',nvl(df.maxbytes,df.bytes),df.bytes)),0) maxbytes,
       nvl(sum(df.bytes),0) bytes,
       0 freebytes
from dba_tablespaces ts, dba_temp_files df
where ts.status='ONLINE'
and ts.contents='TEMPORARY'
and df.tablespace_name=ts.tablespace_name
and df.status='ONLINE'
GROUP BY ts.tablespace_name
UNION ALL
select fr.tablespace_name,
       0 maxbytes,
       0 bytes,
       nvl(sum(fr.free_space),0) freebytes
from dba_temp_free_space fr
group by fr.tablespace_name
) t
group by t.tablespace_name
order by 5;


---------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------
