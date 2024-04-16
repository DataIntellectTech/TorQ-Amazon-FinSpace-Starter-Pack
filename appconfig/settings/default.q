system"c 23 2000"

.usage.logtodisk:0b;                            // disable usage logging as we cannot write to disk in finspace

.servers.FINSPACEDISC:1b;

//-- .servers.procstab will be overwritten by trackservers.q on servers initiation
.servers.SOCKETTYPE:{x!count[x]#`finspace} exec distinct proctype from .servers.procstab:("S*SS*BBHH*B**";enlist ",") 0: .proc.file;

.finspace.enabled:1b;
.finspace.database:getenv[`KDBDATABASETRADE];
.finspace.hdbclusters:enlist `$"hdb1";          // TODO : Deprecate for phase 2
.finspace.rollovermode:`daily;		              // [ `daily | `period ] set to `daily for once per day writedown (end of day). `period for intraday writedown and use of our rolling setup (new rdb/wdb/hdb start and the old rdb/wdb/hdb shutdown every set period)
.finspace.dataview:getenv[`KDBDATAVIEW];
.finspace.hdbreloadmode:"ROLLING";              // [ "ROLLING" | "NO_RESTART" ] mode can either be "ROLLING" or "NO_RESTART"
.finspace.cache:();                             // [ () | .aws.cache["CACHE_1000";"/"] ] cache to reload hdbs with

.finspace.rollovermode:`daily;		/[ `daily | `period ] set to `daily for once per day writedown (end of day). `period for intraday writedown and use of our rolling setup (new rdb/wdb/hdb start and the old rdb/wdb/hdb shutdown every set period)

// hb subscriptions keeps the connections alive
.hb.subenabled:1b;

svrstoload:select from .servers.procstab where proctype = .proc.proctype;
$[count toload:first (select from svrstoload where procname=.proc.procname)`load;
  .proc.params[`load]:enlist .rmvr.removeenvvar toload;
  if[count svrstoload; .proc.params[`load]:enlist .rmvr.removeenvvar first svrstoload`load]
 ];
