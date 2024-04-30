
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