# Oracle Database, Tablespace Auto Add datafiles

## Usage:
- execute numbered scripts
- confirm proper execution
- schedule via scheduler job or other
- configure tresholds in "operationsconfig" table. 
    -   Ex: Add 3 datafiles/hour
- monitor this process using "operationslog" table using TABLESPACES_V2 view.
    -   Ex: tablespace is getting full because of application bug (+3 datafiles added in the last hour)
