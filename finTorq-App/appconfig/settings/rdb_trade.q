depth:([]sym:`g#`symbol$();time:`timestamp$();bid1:`float$();bsize1:`int$();bid2:`float$();bsize2:`int$();bid3:`float$();bsize3:`int$();ask1:`float$();asize1:`int$();ask2:`float$();asize2:`int$();ask3:`float$();asize3:`int$());

quotes:([]sym:`g#`symbol$();time:`timestamp$();src:`symbol$();bid:`float$();ask:`float$();bsize:`int$();asize:`int$());

trades:([]sym:`g#`symbol$();time:`timestamp$();src:`symbol$();price:`float$();size:`int$());

\d .finspace

database:getenv[`KDBDATABASETRADE];
hdbclusters:enlist `$"oregan-fintorq-hdb-trade";

\d .

\d .rdb
hdbdir:hsym`$getenv[`KDBSCRATCH]    // the location of the hdb directory
reloadenabled:0b                    // if true, the RDB will not save when .u.end is called but
                                    // will clear it's data using reload function (called by the WDB)


timeout:system"T"
connectonstart:0b                   // rdb connects and subscribes to tickerplant on startup
tickerplanttypes:`segmentedtickerplant
gatewatypes:`none
replaylog:1b

hdbtypes:()                         //connection to HDB not needed

subfiltered:0b
// path to rdbsub{i}.csv
subcsv:hsym first `.proc.getconfigfile["rdbsub/rdbsub",(3_string .proc`procname),".csv"];

