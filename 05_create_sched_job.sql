--- Create Job
 BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
            job_name => 'dba_ops."OMIX_ADD_DATAFILE"',
            job_type => 'STORED_PROCEDURE',
            job_action => 'dba_ops.PK_OPERATIONS.PR_ADD_DATAFILE',
            number_of_arguments => 0,
            start_date => NULL,
            repeat_interval => 'FREQ=MINUTELY;INTERVAL=30',
            end_date => NULL,
            enabled => FALSE,
            auto_drop => FALSE,
            comments => 'exec dba_ops.pk_operations.pr_add_datafile;');
    DBMS_SCHEDULER.SET_ATTRIBUTE( 
             name => 'dba_ops."OMIX_ADD_DATAFILE"', 
             attribute => 'logging_level', value => DBMS_SCHEDULER.LOGGING_FULL);
    DBMS_SCHEDULER.enable(
             name => 'dba_ops."OMIX_ADD_DATAFILE"');
END;
