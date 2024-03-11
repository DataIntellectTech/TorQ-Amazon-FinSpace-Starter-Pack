\d .finspace

database:getenv[`KDBDATABASETRADE];
hdbclusters:enlist `$"hdb1";        // TODO : Deprecate for phase 2

\d .rdb
hdbdir:hsym`$getenv[`KDBSCRATCH]    // the location of the hdb directory
reloadenabled:0b                    // if true, the RDB will not save when .u.end is called but
                                    // will clear it's data using reload function (called by the WDB)

timeout:system"T"

hdbtypes:()                         //connection to HDB not needed

// path to rdbsub{i}.csv
subcsv:hsym first `.proc.getconfigfile["rdbsub/rdbsub",(3_string .proc`procname),".csv"];

\d .servers
CONNECTIONS:`rdb`wdb                // if connectonstart false,include tickerplant in tickerplanttypes, not in CONNECTIONS
STARTUP:1b 
