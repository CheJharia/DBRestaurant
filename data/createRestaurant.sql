-- print results to logfile
SPOOL logfile
start dataDefinition.sql;
start dataManipulation.sql;
-- turn of spool
SPOOL OFF
