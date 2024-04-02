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
  if[(.eodtime.nextroll < x) & .finspace.rollovermode<>`period;
    if[.eodtime.d<("d"$x)-1;system"t 0";'"more than one day?"]; endofday[.eodtime.d;.stplg.endofdaydata[],(enlist `p)!enlist x]];
 };

createdld:{[name;date]
  .stplg.dldir:`$.stplg.kdbtplog;
 };

\d .

upd:{[t;x]
  if[t~`heartbeat;.hb.storeheartbeat[x];:()];
  x:value flip x;
  .u.upd[t;x]
 };
