
\d .gw

//overwrite this method to not upsert null handles
addserversfromconnectiontable:{
 {.gw.addserverattr'[x`w;x`proctype;x`attributes]}[select w,proctype,attributes from .servers.SERVERS where ((proctype in x) or x~`ALL),not w in ((0;0Ni),exec handle from .gw.servers where not null handle)];}

//update the server active flag in .gw.servers
setserveractiveflag:{[servername;isactive]
  if[count res:(select handle:w, procname from .servers.SERVERS where procname in servername) lj `handle xkey .gw.servers;
     update active:isactive from `.gw.servers where serverid in (exec serverid from res);
   ];
 };

//a function to simultaniously deactivate old services and active new ones. Updates the server active flag in .gw.servers
setserverreplacement:{[oldserver;newserver]
  oldserverdetails:(select handle:w, procname from .servers.SERVERS where procname in oldserver) lj `handle xkey .gw.servers;
  newserverdetails:(select handle:w, procname from .servers.SERVERS where procname in newserver) lj `handle xkey .gw.servers;
  
  //seperating out the calls and checks as we would still want the active flag to be set even if old one is down
  if[count newserverdetails;
     update active:1b from `.gw.servers where serverid in (exec serverid from newserverdetails);
     if[count oldserverdetails;
       update active:0b from `.gw.servers where serverid in (exec serverid from oldserverdetails);
     ];
   ];
 };

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
  .finspace.dereginprog:0<count deregserverids _ 0N;
 }
