system"c 23 2000"

.usage.logtodisk:0b;                            // disable usage logging as we cannot write to disk in finspace

.servers.FINSPACEDISC:1b;
.servers.FINSPACECLUSTERSFILE:hsym `$getenv[`KDBAPPCONFIG],"/clusters.csv"

.servers.CLUSTERS:("SSSS**"; enlist ",") 0: .servers.FINSPACECLUSTERSFILE;
.servers.SOCKETTYPE:{x!count[x]#`finspace} exec distinct proctype from .servers.CLUSTERS;

.finspace.enabled:1b;
.finspace.database:getenv[`KDBDATABASETRADE];
.finspace.hdbclusters:enlist `$"hdb1";          // TODO : Deprecate for phase 2
.finspace.rollovermode:`daily;		              // [ `daily | `period ] set to `daily for once per day writedown (end of day). `period for intraday writedown and use of our rolling setup (new rdb/wdb/hdb start and the old rdb/wdb/hdb shutdown every set period)
.finspace.dataview:getenv[`KDBDATAVIEW];
.finspace.hdbreloadmode:"ROLLING";              // [ "ROLLING" | "NO_RESTART" ] mode can either be "ROLLING" or "NO_RESTART"
.finspace.cache:();                             // [ () | .aws.cache["CACHE_1000";"/"] ] cache to reload hdbs with

// hb subscriptions keeps the connections alive
.hb.subenabled:1b;

if[count toload:exec first toload from .servers.CLUSTERS where proctype = .proc.proctype, procname=.proc.procname;
    .proc.params[`load]:enlist .rmvr.removeenvvar toload
    ];
