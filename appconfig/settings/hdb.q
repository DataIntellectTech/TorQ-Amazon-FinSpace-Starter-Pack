
.servers.postrefreshfunc:{
  rdbs:exec w from .servers.SERVERS where proctype = `rdb, .dotz.liveh w;
  func:{[pt] cleartabledelayed[pt]'[key .rdb.neweodcounts;first each value .rdb.neweodcounts] };
  rdbs @\: (func;.z.d);
 };

.servers.postrefreshfunc:(.servers.postrefreshfunc;`);