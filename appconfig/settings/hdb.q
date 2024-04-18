
.servers.postrefreshfunc:{
  rdbs:exec w from .servers.SERVERS where proctype = `rdb, .dotz.liveh w;
  func:{[pt] cleartabledelayed[pt]'[key .rdb.neweodcounts;first each value .rdb.neweodcounts] };
  rdbs @\: (func;last .Q.PV);
 };

.servers.postrefreshfunc:(.servers.postrefreshfunc;`);