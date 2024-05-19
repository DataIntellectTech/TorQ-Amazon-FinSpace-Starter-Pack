
//called after new HDB cluster finishes loading all dependencies
//triggers RDB reload instead of the HDB and removes old HDB cluster if it is a replacement
.hdb.startup:{
  gws:exec w from .servers.SERVERS where proctype = `gateway, .dotz.liveh w;
  if[not count gws; :()]; // TODO : Handle case when none

  // set this hdb to inactive if exists
  gws @\: (`.gw.setserveractiveflag;.proc.procname;0b);
  // wait for status change
  .finspace.checkstatus[(.finspace.getcluster;.proc.procname);("RUNNING";"FAILURE");00:01;0D01];
  // identify the row and retry connection
  {[h;tgt]
     tgtidx:first @[h;({exec i from .servers.SERVERS where procname=x};tgt);()];
     if[null tgtidx; :()];
     doretry:@[h;({null .servers.SERVERS[x][`w]};tgtidx);1b];
     .lg.o[`hdbstartup;"will force retry row ",(-3!tgtidx)," in servers.SERVERS for gw handle ",(-3!h)," : ",-3!doretry];
     if[doretry; h(`.servers.retryrows;tgtidx)];
   }[;.proc.procname] each gws;
   gws @\: (`.gw.setserveractiveflag;.proc.procname;1b);

  .lg.o[`hdbstartup;"trigger rdbs to remove rows found at eod"];
  rdbs:exec w from .servers.SERVERS where proctype = `rdb, .dotz.liveh w;
  func:{ if[`eodtabcount in key .rdb; .rdb.reload[x]] };
  rdbs @\: (func;.z.d);
  .lg.o[`hdbstartup;"finished signaling rdbs to drop rows at time of eod"];

  if[count deleteme:first .proc.params[`replaceProc];
      .lg.o[`hdbstartup;"sending signal to delete the cluster named ",deleteme];
      gws @\: (`.finspace.unregisterfromgw;enlist `$deleteme);
    ];
  .lg.o[`hdbstartup;"finishing hdb startup"];
 };

.proc.addinitlist(`.hdb.startup;`);

/
Original functionality - keep as reference

//called after new HDB cluster finishes loading all dependencies
//triggers RDB reload instead of the HDB and removes old HDB cluster if it is a replacement
.hdb.startup:{
  .lg.o[`hdbstartup;"trigger rdbs to remove rows found at eod"];
  rdbs:exec w from .servers.SERVERS where proctype = `rdb, .dotz.liveh w;
  func:{ if[`eodtabcount in key .rdb; .rdb.reload[x]] };
  rdbs @\: (func;.z.d);
  .lg.o[`hdbstartup;"finished signaling rdbs to drop rows at time of eod"];

  if[count deleteme:first .proc.params[`replaceProc];
    if[count gws:exec w from .servers.SERVERS where proctype = `gateway, .dotz.liveh w;
      .lg.o[`hdbstartup;"sending signal to delete the cluster named ",deleteme];
      (first gws)(`.finspace.unregisterfromgw;enlist `$deleteme)
     ];
   ];
  .lg.o[`hdbstartup;"finishing hdb startup"];
 };

.proc.addinitlist(`.hdb.startup;`);
