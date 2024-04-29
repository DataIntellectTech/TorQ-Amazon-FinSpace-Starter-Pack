
.hdb.startup:{
  //david handle deletion

  .lg.o[`hdbstartup;"trigger rdbs to remove rows found at eod"];
  rdbs:exec w from .servers.SERVERS where proctype = `rdb, .dotz.liveh w;
  func:{ if[`eodtabcounts in key .rdb; .rdb.reload[]] };
  rdbs @\: (func;`);
  //rdbs @\: (`.rdb.reload;`)
 };

.proc.addinitlist(`.hdb.startup;`);

\d .servers

CONNECTIONS:`rdb`gateway;




.servers.postrefreshfunc:{
  rdbs:exec w from .servers.SERVERS where proctype = `rdb, .dotz.liveh w;
  func:{[pt] .rdb.cleartabledelayed[pt]'[key .rdb.neweodcounts;(value .rdb.neweodcounts)[;1]] };
  rdbs @\: (func;.z.d);
 };