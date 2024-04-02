system "l ",getenv[`TORQAPPHOME],"/code/rdb/schema.q"

\d .finspace

database:getenv[`KDBDATABASETRADE];
hdbclusters:enlist `$"hdb1";        // TODO : Deprecate for phase 2

\d .rdb
hdbdir:hsym`$getenv[`KDBSCRATCH]    // the location of the hdb directory
reloadenabled:0b                    // if true, the RDB will not save when .u.end is called but
                                    // will clear it's data using reload function (called by the WDB)
hdbdataviewname:"finTorq_dataview"  // name of the dataview used by hdb

timeout:system"T"
connectonstart:0b                   // rdb connects and subscribes to tickerplant on startup
tickerplanttypes:`segmentedtickerplant
gatewatypes:`none
replaylog:.finspace.rollovermode<>`period;      // if in rollovermode=`period turn off tp log replay
                                                // as we don't want the current period, we want the next one

hdbtypes:()                         //connection to HDB not needed

subfiltered:0b
// path to rdbsub{i}.csv
subcsv:hsym first `.proc.getconfigfile["rdbsub/rdbsub",(3_string .proc`procname),".csv"];
