// Bespoke RDB config : Finance Starter Pack

\d .rdb
hdbdir:hsym`$getenv[`KDBSCRATCH]        // the location of the hdb directory
reloadenabled:0b                    // if true, the RDB will not save when .u.end is called but
                                    // will clear it's data using reload function (called by the WDB)


timeout:system"T"
connectonstart:0b                   // rdb connects and subscribes to tickerplant on startup
tickerplanttypes:`segmentedtickerplant
gatewatypes:`none
replaylog:1b
finspace:1b

hdbtypes:()                         //connection to HDB not needed

subfiltered:0b
// path to rdbsub{i}.csv
subcsv:hsym first `.proc.getconfigfile["rdbsub/rdbsub",(3_string .proc`procname),".csv"]

\d .servers

CONNECTIONS:enlist `gateway         // if connectonstart false, include tickerplant in tickerplanttypes, not in CONNECTIONS

\d .

// TODO - EOD needs to be triggered via the timer once it becomes unlocked so this code will need to be tested once we're unblocked
/.timer.rep[`timestamp$.proc.cd[]+00:00;0Wp;1D;(`.u.end;.proc.cd[];`);0h;"Running RDB End of Day";1b]];
