
\d .rdb
hdbdir:hsym`$getenv[`KDBSCRATCH]    // the location of the hdb directory
reloadenabled:1b                    // if true, the RDB will not save when .u.end is called but
                                    // will clear it's data using reload function (called by the WDB)
ignorelist:`heartbeat`logmsg`svrstoload         // list of tables to ignore when saving to disk
timeout:system"T"

replaylog:.finspace.rollovermode<>`period;      // if in rollovermode=`period turn off tp log replay
                                                // as we don't want the current period, we want the next one

hdbtypes:()                         // connection to HDB not needed

// path to rdbsub{i}.csv
subcsv:hsym first `.proc.getconfigfile["rdbsub/rdbsub",(3_string .proc`procname),".csv"];

\d .servers
CONNECTIONS:`rdb`wdb                // if connectonstart false,include tickerplant in tickerplanttypes, not in CONNECTIONS
