
\d .gw

//overwrite this method to not upsert null handles
addserversfromconnectiontable:{
 {.gw.addserverattr'[x`w;x`proctype;x`attributes]}[select w,proctype,attributes from .servers.SERVERS where ((proctype in x) or x~`ALL),not w in ((0;0Ni),exec handle from .gw.servers where not null handle)];}

\d .finspace

deregserverids:(enlist 0N)!enlist (::);

unregisterfromgw:{[servernames]
   // identify the serverid by mapping the handles in .server.SERVERS and .gw.servers
   deregservers:(select handle:w, procname from .servers.SERVERS where procname in servernames, not null w) ij `handle xkey .gw.servers;
   svrIDs:exec serverid from deregservers;
   if[not count svrIDs; .lg.o[`unregisterfromgw;"No servers to deregister. Aborting"]; :()];

   // block incoming queries to these processes
   update active:0b,disconnecttime:.proc.cp[] from `.gw.servers where serverid in svrIDs;

   // update variables
   @[`.finspace.deregserverids;svrIDs;:;exec handle from deregservers];
   .finspace.dereginprog:1b; // we can do something with rdbready when we get a clearer picture

   // try deregistering
   checkremainingqueriesforserver'[svrIDs];
 };

// checks if there are any remaining queries for serverid
checkremainingqueriesforserver:{[serverid]
  if[null deregserverids[serverid]; :()];
  if[not count where {[dict;id] byId:where id=dict[1;;0]; not all dict[1;byId;2] }[;serverid] each .gw.results _ 0Ni;
     @[.finspace.sigserverexit;serverid;{.lg.o[`sigserverexit;"attempt to close server on cluster with id ",(.Q.s1 serverid)," failed due to error: ",-3!x];}]
   ];
 };

// wrapper to signal a server exit from gateway on finspace
sigserverexit:{[serverid]
  serverhandle:deregserverids[serverid];
  neg[serverhandle](`.finspace.deletecluster;"");
  .finspace.deregserverids:deregserverids _ serverid;
  .finspace.dereginprog:"b"$count deregserverids _ 0N;
 }
