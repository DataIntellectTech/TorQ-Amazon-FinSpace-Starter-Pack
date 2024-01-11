//This is only for finspace
\d .rdb

pollNewSvrStatus:{[svrName;W]
  stat:first exec status from .aws.list_kx_clusters[] where cluster_name like string svrName;
  if[not stat~"RUNNING"; .lg.o[`pollNewSvrStatus;(-3!svrName)," still not ready"]; :(::)];
  
  hdisc:@[hopen;.aws.get_kx_connection_string "discovery";{-3!x}]; // edit this to use .servers.SERVERS 
  if[6h~type hdisc; hdisc(`.lg.o;`pollNewSvrStatus;"just being triggered from the rdb"); hclose hdisc];
  .timer.remove each exec id from .timer.timer where `.rdb.pollNewSvrStatus in' funcparam;
 };

killMyself:{[caller]
  .lg.o[`killMyself;"I am being called by ",-3!caller];
  //assume the cluster_name and procname are the same
  //set up a timer that checks the status of the cluster_name and attempts to open a handle. If success then do nothin
  //afterwards inform the discovery to redirect the thing
  .timer.repeat[.proc.cp[];0Wp;0D00:02;(`.rdb.pollNewSvrStatus;caller;.z.w);"poll for running RDB"];
 };
 
signalOldCluster:{[]
 if[`replaceCluster in key .Q.opt .z.x;
   tmpHandle:@[hopen;.aws.get_kx_connection_string raze (.Q.opt .z.x)`replaceCluster;{-3!x}];
   if[-6h<>type tmpHandle; .lg.e[`signalOldCluster;tmpHandle]; :(::)];
   tmpHandle(`killMyself;.proc.procname);
   hclose tmpHandle;
  ];
 };

//signalOldCluster[];

// eventually have this connect to the tickerplant instead
subscribeToFeed:{[svrName]
 retDefault:(0b;());
 if[not @[get;`.rdb.feedDidSub;0b];
  .rdb.feedHandle:@[{hopen .aws.get_kx_connection_string x};;{ .lg.o[`subscribeToFeed;"error: ",-3!x]; :retDefault}] string svrName;
  res:.rdb.feedHandle(`.u.sub;`;`);
  .timer.remove each exec id from .timer.timer where `.rdb.subscribeToFeed in' funcparam;
  :(.rdb.feedDidSub:1b;res)
 ];
 retDefault
 };

startSubscribeToFeed:{[]
 clusterID:exec first cluster_name from .servers.CLUSTERS where proctype=`tradeFeed;
 .timer.repeat[.proc.cp[];0Wp;0D00:02;(`.rdb.subscribeToFeed;clusterID);"poll for running feed"];
 };

startSubscribeToFeed[]

/
zedPortOpen.handlers:()!();
zedPortOpen.handlers[`feed]:{ signalOldCluster[] };

dotZedPortOpen:{
  @[zedPortOpen.handlers[.z.u];x;{.lg.o[.dotz.getcommand[`.z.po];"failed to call function for user ",-3!x]} .z.u]
 };

.dotz.set[`.z.po;dotZedPortOpen];