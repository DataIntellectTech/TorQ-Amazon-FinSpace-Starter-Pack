\d .eqp

//overwrite partitionfilter func to cast partrange to int
extractpartitionfilter:{[inputparams;queryparams]
  //If an RDB return the partitionfilters as empty
  if[`rdb~inputparams[`metainfo;`proctype];:@[queryparams;`partitionfilter;:;()]];
  //Get the  partition range function
  getpartrangef:.checkinputs.gettableproperty[inputparams;`getpartitionrange];
  // Get the time column
  timecol:inputparams`timecolumn;
  // Get the time range function
  timerange:inputparams[`metainfo]`starttime`endtime;
  // Find the partition field
  partfield:.checkinputs.gettableproperty[inputparams;`partfield];
  //return a list of partions to search through
  //casting to long to account for int partitions in finspace 
  partrange:`long$`timestamp$.dacustomfuncs.partitionrange[(inputparams`tablename);timerange;.proc.proctype;timecol];
  // Return as kdb native filter
  partfilter:exec enlist(within;partfield;partrange)from inputparams;
  :@[queryparams;`partitionfilter;:;partfilter];
  };
