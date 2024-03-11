\d .dataaccess

// Dynamic routing finds all processes with relevant data
attributesrouting:{[options;procdict]
    // Get the tablename and timespan
    timespan:`long$options[`starttime`endtime];
    //adjust rdb partition range to account for period end time)
    if[`rdb in key procdict;procdict[`rdb]:(first[procdict `rdb];-1+`long$01D00 + last procdict `rdb)];
    // See if any of the provided partitions are with the requested ones
    procdict:{[x;timespan] (all x within timespan) or any timespan within x}[;timespan] each procdict;
    // Only return appropriate dates
    types:(key procdict) where value procdict;
    // If the dates are out of scope of processes then error
    if[0=count types;
        '`$"gateway error - no info found for that table name and time range. Either table does not exist; attributes are incorect in .gw.servers on gateway, or the date range is outside the ones present"
       ];
    :types;
    };

// function to adjust the queries being sent to processes to prevent overlap of
// time clause and data being queried on more than one process
adjustqueries:{[options;part]
    // if only one process then no need to adjust
    if[2>count p:options`procs;:options];
    // get the partitions that are required by each process
    tabname:options[`tablename];
    // Remove duplicate servertypes from the gw.servers
    servers:select from .gw.servers where i=(first;i)fby servertype;
    // extract the procs which have the table defined
    servers:select from servers where {[x;tabname]tabname in @[x;`tables]}[;tabname] each attributes;
    // Create a dictionary of the attributes against servertypes
    procdict:(exec servertype from servers)!(exec attributes from servers)@'(key each exec attributes from servers)[;0];
    // If the response is a dictionary index into the tablename
    procdict:@[procdict;key procdict;{[x;tabname]if[99h=type x;:x[tabname]];:x}[;tabname]];
    //create list of all possible partitions
    possparts:raze value procdict;
    
    st:`long$$[a:-12h~tp:type start:options`starttime;start;`timestamp$start];
    //get partitions required by each proc
    partitions:group key[part]where each{within[y;]each value x}[part]'[possParts];
    partitions:possParts{(min x;max x)}'[partitions];
    //cast the partitions to timestamps
    dates:`timestamp$partitions;

    //adjust the times to account for period end time
    //set hdb end to be before rdb partition start time
    c:first[x:@[dates;`hdb]],-1+ first[@[dates;`rdb]];
    //if rdb is in part then endtime must be after rdb partition starttime
    d:first[@[dates;`rdb]],options `endtime;
    dates:@[@[dates;`hdb;:;c];`rdb;:;d];

   //if start/end time not a date, then adjust dates parameter for the correct types
    if[not a;
      //converts dates dictionary to timestamps/datetimes
      dates:$[-15h~tp;{"z"$x};::]{(0D+x 0;x[1]+1D-1)}'[dates];

      //convert first and last timestamp to start and end time
      dates:@[dates;f;:;(start;dates[f:first key dates;1])];
      dates:@[dates;l;:;(dates[l:last key dates;0];options`endtime)]];

   //adjust map reducable aggregations to get correct components
    if[(1<count dates)&`aggregations in key options;
        if[all key[o:options`aggregations]in key aggadjust;
            aggs:mapreduce[o;$[`grouping in key options;options`grouping;`]];
            options:@[options;`aggregations;:;aggs]]];

    // create a dictionary of procs and different queries
    :{@[@[x;`starttime;:;y 0];`endtime;:;y 1]}[options]'[dates];
    };
           

