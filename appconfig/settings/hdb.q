
.servers.postrefreshfunc:{
  // inform the rdb about stuff
  rdbs:exec w from .servers.SERVERS where proctype = `rdb, .dotz.liveh w;
  .et.rdbs:rdbs;
 };

.servers.postrefreshfunc:(.servers.postrefreshfunc;`);