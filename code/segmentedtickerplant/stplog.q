// Utilites for periodic tp logging in stp process

\d .stplg

// In Finspace there is no need for EOD, only EOP as there is nothing extra EOD can do that EOP doesn't in Finspace
checkends:{
  // jump out early if don't have to do either
  if[nextendUTC > x; :()];
  // check for endofperiod
  // TODO ZAN will need to change the below line so that eod doesn't stop it
  if[nextperiod < x1:x+.eodtime.dailyadj;
    stpeoperiod[.stplg`currperiod;.stplg`nextperiod;.stplg.endofdaydata[],(enlist `p)!enlist x1;1b]];
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
    // TODO ZAN using currperiod here, will that overwrite the log if the tp restarts?
    openlog[multilog;dldir;;currperiod]each logtabs;
    // read in the meta table from disk 
    .stpm.metatable:@[get;hsym`$string[.stplg.dldir],"/stpmeta";0#.stpm.metatable];
    // set log sequence number to the max of what we've found
    i::1+ -1|exec max seq from .stpm.metatable;
    // add the info to the meta table
    .stpm.updmeta[multilog][`open;logtabs;.z.p+.eodtime.dailyadj];
    ]
 };
