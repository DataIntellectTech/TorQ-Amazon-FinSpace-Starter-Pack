
.gw.DEREGCHECKFREQ:@[value;`.gw.DEREGCHECKFREQ;0D00:00:10];

.finspace.unregisterfromgw:{[servernames]
   // identify the serverid by mapping the handles in .server.SERVERS and .gw.servers
   svrIDs:exec serverid from deregservers:(select handle:w, procname from .servers.SERVERS where procname in servernames, not null w) ij `handle xkey .gw.servers;
   if[not count svrIDs; .lg.o[`unregisterfromgw;"No servers to deregister. Aborting"]; :()];

   // block incoming queries to these processes
   update active:0b from `.gw.servers where serverid in svrIDs;
   
   timerID:first 1?0Ng;
   .timer.repeat[.proc.cp[];0Wp;.gw.DEREGCHECKFREQ;(`.finspace.checkremainingqueries;timerID;svrIDs;update flagdown:0b from deregservers);"check if pending queries in servernames"]
 };

// timerid     | -2h | guid identifier to help remove instance of this function if multiple instances of this function are scheduled
// serversid   | 6h  | ids of the servers to deregister
// serversinfo | 98h | table with info about the servers to deregister
.finspace.checkremainingqueries:{[timerid;serverids;serversinfo]
   whereComplete:serverids where .finspace.checkremainingqueriesforserver each serverids;
   serversinfo:update flagdown:1b from serversinfo where serverid in raze @'[.finspace.sigserverexit[;serversinfo];whereComplete;{:()}];

   if[all serversinfo`flagdown;
      .timer.remove @/: exec id from .timer.timer where `.finspace.checkremainingqueries in' funcparam, timerid in' funcparam;
      :(::);
     ]; 

   if[count incompleteservers:exec procname from serversinfo where not serverid in whereComplete;
      .lg.o[`checkremainingqueries;"servers ",(.Q.s1 incompleteservers), " still have remaining queries"]];
 };

.finspace.checkremainingqueriesforserver:{[serverid]
   not count where {[dict;id] byId:where id=dict[1;;0]; not all dict[1;byId;2] }[;serverid] each .gw.results _ 0Ni
 };

.finspace.sigserverexit:{[id;sInfo]
    dict:first select from sInfo where serverid=id;

    // if this server was already shutdown or has disconnected for any reason, return the serverid
    if[(dict`flagdown) or (null first exec handle from .gw.servers where serverid=id); :id];
    
    $[count select from .gw.servers where active, servertype=dict`servertype, handle<>dict`handle; [neg[dict`handle]"exit 0"; :id]; ()]
  };