system"c 23 2000"

.usage.logtodisk:0b; / disable usage logging as we cannot write to disk in finspace

.servers.FINSPACEDISC:1b;
.servers.FINSPACECLUSTERSFILE:hsym `$getenv[`KDBAPPCONFIG],"/clusters.csv"

.servers.CLUSTERS:("SSSS**"; enlist ",") 0: .servers.FINSPACECLUSTERSFILE;
.servers.SOCKETTYPE:{x!count[x]#`finspace} exec distinct proctype from .servers.CLUSTERS;

.finspace.enabled:1b;

// hb subscriptions keeps the connections alive
.hb.subenabled:1b;

svrstoload:select from .servers.CLUSTERS where proctype = .proc.proctype
$[count toload:first exec toload from svrstoload where procname = .proc.procname;
  .proc.params[`load]:enlist .rmvr.removeenvvar toload;
  if[count svrstoload; .proc.params[`load]:enlist .rmvr.removeenvvar first exec toload from svrstoload]
 ];
