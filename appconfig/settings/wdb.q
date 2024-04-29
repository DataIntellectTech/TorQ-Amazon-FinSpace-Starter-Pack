// when rollovermode=`period wdb is designed to be 1:1 relationship with periods.Therefore every new period will have a new wdb.
\d .wdb
replay:.finspace.rollovermode<>`period;         // if in rollovermode=`period turn off tp log replay
                                                // as we don't want the current period, we want the next one
ignorelist:`heartbeat`logmsg`svrstoload         // list of tables to ignore when saving to disk
savedir:hsym`$getenv[`KDBSCRATCH];              // the location of the hdb directory
hdbdir:hsym`$getenv[`KDBSCRATCH];
reloadorder:enlist `hdb;                      // we might not want to reload the rdb until the new hdb is up

\d .finspace
database:getenv[`KDBDATABASETRADE];
hdbclusters:enlist `$"hdb1";                    // TODO : Deprecate for phase 2
dataview:getenv[`KDBDATAVIEW];
