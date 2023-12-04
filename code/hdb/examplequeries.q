/- HDB query for counting by sym
countbysym:{[startdate;enddate]
 select sum size, tradecount:count i by sym from trade where date within (startdate;enddate)}

/- time bucketted count
hloc:{[startdate;enddate;bucket]
 select high:max price, low:min price, open:first price,close:last price,totalsize:sum `long$size, vwap:size wavg price
 by sym, bucket xbar time
 from trade
 where date within (startdate;enddate)}

getQryPerf:{[qry;src] start:.z.p; res:value qry; sz:(-22!res)%1024; exectime:.z.p-start; t:"i"$"t"$exectime; ([] rows:enlist count res; sizeKB:enlist sz;ms:enlist t;startTime:enlist start; query:enlist qry; querySource:enlist src)}

