
.hdb.startup:{[]
  resp:.finspace.getcluster .proc.procname;
  if[resp[`status]~"UPDATING";
    //burn cpu until status is "RUNNING"
    res:.finspace.checkstatus[(`.finspace.getcluster;.proc.procname);("RUNNING";"FAILURE");00:01;0D02];
    if[res[`status]<>"RUNNING"; :()];

    // refresh connections + clear RDB data
    if[count d:exec i from `.servers.SERVERS where proctype=`discovery, .dotz.liveh w;
       .servers.reqdiscoveryretryallfinspaceconn[first d]];
  ];
 };

.hdb.startup[]

