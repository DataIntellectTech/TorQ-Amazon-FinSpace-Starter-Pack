system"c 23 2000"

.usage.logtodisk:0b; / disable usage logging as we cannot write to disk in finspace

.servers.FINSPACEDISC:1b;

.servers.CLUSTERS:("SSSS**"; enlist ",") 0: .servers.FINSPACECLUSTERSFILE;

.finspace.enabled:1b;

.finspace.rollovermode:`daily;		/[ `daily | `period ] set to `daily for once per day writedown (end of day). `period for intraday writedown and use of our rolling setup (new rdb/wdb/hdb start and the old rdb/wdb/hdb shutdown every set period)

// hb subscriptions keeps the connections alive
.hb.subenabled:1b;

svrstoload:select from .servers.procstab where proctype = .proc.proctype;
$[count toload:first (select from svrstoload where procname=.proc.procname)`load;
  .proc.params[`load]:enlist .rmvr.removeenvvar toload;
  if[count svrstoload; .proc.params[`load]:enlist .rmvr.removeenvvar first svrstoload`load]
 ];
