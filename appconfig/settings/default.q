system"c 23 2000"

.usage.logtodisk:0b; / disable usage logging as we cannot write to disk in finspace

.servers.FINSPACEDISC:1b;

.servers.SOCKETTYPE:{x!count[x]#`finspace} exec distinct proctype from .servers.procstab:("S*SS*BBHH*B**";enlist ",") 0: .proc.file;

.finspace.enabled:1b;

// hb subscriptions keeps the connections alive
.hb.subenabled:1b;

svrstoload:select from .servers.procstab where proctype = .proc.proctype;
$[count toload:first ?[svrstoload;enlist (=;`procname;(),.proc.procname);();`load];
  .proc.params[`load]:enlist .rmvr.removeenvvar toload;
  if[count svrstoload; .proc.params[`load]:enlist .rmvr.removeenvvar first ?[svrstoload;();();`load]]
 ];
