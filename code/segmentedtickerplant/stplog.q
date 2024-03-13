// Utilites for periodic tp logging in stp process

\d .stplg

checkends:{
  // jump out early if don't have to do either
  if[nextendUTC > x; :()];
  // when rollovermode=`period we always want to rolllogs as EOD doesn't run, only EOP
  rolllogs:$[.finspace.rollovermode~`period;1b;not .eodtime.nextroll < x];
  // check for endofperiod
  if[nextperiod < x1:x+.eodtime.dailyadj;
    stpeoperiod[.stplg`currperiod;.stplg`nextperiod;.stplg.endofdaydata[],(enlist `p)!enlist x1;rolllogs]];
  // check for endofday
  // In Finspace there is no need for EOD in rollovermode=`period, only EOP as there is nothing extra EOD can do that EOP doesn't
  if[(.eodtime.nextroll < x) & not .finspace.rollovermode~`period;
    if[.eodtime.d<("d"$x)-1;system"t 0";'"more than one day?"]; endofday[.eodtime.d;.stplg.endofdaydata[],(enlist `p)!enlist x]];
 };

init:{[dbname]
  t::tables[`.]except `currlog;
  msgcount::rowcount::t!count[t]#0;
  tmpmsgcount::tmprowcount::(`symbol$())!`long$();
  logtabs::$[multilog~`custom;key custommode;t];
  rolltabs::$[multilog~`custom;logtabs except where custommode in `tabular`singular;t];
  currperiod::multilogperiod xbar .z.p+.eodtime.dailyadj;
  nextperiod::multilogperiod+currperiod;
  getnextendUTC[];
  i::1;
  seqnum::0;
  dldir::`$kdbtplog;
  
  if[(value `..createlogs) or .sctp.loggingmode=`create;
    openlog[multilog;dldir;;.z.p+.eodtime.dailyadj]each logtabs;
    // If appropriate, roll error log
    if[.stplg.errmode;openlogerr[dldir]];
    // read in the meta table from disk 
    .stpm.metatable:@[get;hsym`$string[.stplg.dldir],"/stpmeta";0#.stpm.metatable];
    // set log sequence number to the max of what we've found
    i::1+ -1|exec max seq from .stpm.metatable;
    // add the info to the meta table
    .stpm.updmeta[multilog][`open;logtabs;.z.p+.eodtime.dailyadj];
    ]
 };

\d .

upd:{[t;x]
  if[t~`heartbeat;.hb.storeheartbeat[x];:()];
  x:value flip x;
  .u.upd[t;x]
 };
