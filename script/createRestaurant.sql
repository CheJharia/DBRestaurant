-- print results to logfile
SPOOL logfile
start restaurantDDL.sql;
start restaurantDML.sql;
-- turn of spool
SPOOL OFF
