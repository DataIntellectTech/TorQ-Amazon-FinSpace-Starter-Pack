// Params
\d .feed

/ load settings
nq:@[value;`nq;100];                                //number of quotes to generate
nt:@[value;`nt;100];                                //number of trades to generate
randomcounts:@[value;`randomcounts;0.00000001];
clusters:@[value;`clusters;enlist `cluster];        //which rdb cluster or clusters to point the data to
rnd:{0.01*floor 100*x};
timerperiod:@[value;`timerperiod;0D00:01:00.000];   //the time interval to push new dummy data to the rdb clusters

\d .
// Generates dummy trade, quotes and depth data to be pushed to the rdb
.trade.generateData:{[nq;nt;randomcounts]
 syms:`NOK`YHOO`CSCO`ORCL`AAPL`DELL`IBM`MSFT`GOOG;
 srcs:`N`O`L;
 curr:syms!`EUR`USD`USD`USD`USD`GBP`USD`USD`USD;
 starttime:08:00:00.0;
 hoursinday:08:30:00.0;
 initpxs:syms!20f+count[syms]?30f;
 if[(not -9f=type randomcounts) or not randomcounts within (0;1); '"randomcounts factor should be float within 0 and 1"];
 /- randomize the number of quotes and trades
 nq:`int$nq * 1 + rand[randomcounts]*signum -.5+rand 1f;
 nt:`int$nt * 1 + rand[randomcounts]*signum -.5+rand 1f;
 /- the number of depth ticks - up to
 nd:`int$nq*1.5+rand .5;
 qts:update px*initpxs sym from update px:exp px from update sums px by sym from update px:0.0005*-1+nq?2f from([]time:.z.p;sym:`g#nq?syms;src:`g#nq?srcs);
 qts:select sym,time,src,bid:.feed.rnd px-nq?0.03,ask:.feed.rnd px+nq?0.03,bsize:"i"$(500*1+nq?20),asize:"i"$(500*1+nq?20) from qts;
 trds:update bid:reverse fills reverse bid,ask:reverse fills reverse ask,bsize:reverse fills reverse bsize,asize:reverse fills reverse asize by sym from aj[`sym`time;([]time:.z.p;sym:nt?syms;src:nt?srcs;side:nt?`buy`sell);qts];
 trds:select sym,time,src,price:?[side=`buy;ask;bid],size:`int$(nt?1f)*?[side=`buy;asize;bsize] from trds;
 dpth:update bid:reverse fills reverse bid,ask:reverse fills reverse ask,bsize:reverse fills reverse bsize,asize:reverse fills reverse asize by sym from aj[`sym`time;([]time:.z.p;sym:nd?syms);qts];
 dpth:select sym,time,bid1:bid, bsize1:bsize, bid2:bid-.01, bsize2:"i"$(bsize+500*1+nd?5), bid3:bid-.02,bsize3:"i"$(bsize+500*1+nd?10),ask1:ask, asize1:asize,ask2:ask+.01,asize2:"i"$(asize+500*1+nd?5),ask3:ask+.02,asize3:"i"$(asize+500*1+nd?10) from dpth;

 :(`trades`quotes`depth!(trds;qts;dpth));

 };

.trade.upd:{[w;t;d](neg first w)(`upd;t;d)};

//TODO derive rdb handles through discovery cluster instead of generating

.trade.updateRDB:{
 rdbHandles:@[{hopen .aws.get_kx_connection_string[x]};;.lg.o[`updateRDB;"failed to get handle(s)"]] each .feed.clusters;
 tradedata:.trade.generateData[.feed.nq;.feed.nt;.feed.randomcounts];
 {[handle;data].trade.upd[handle;;]'[key data;value data]}[;tradedata] each rdbHandles
  };

.trade.endofday:{
 rdbHandles:@[{hopen .aws.get_kx_connection_string[x]};;.lg.o[`updateRDB;"failed to get handle(s)"]] each .feed.clusters;
 {[handle;dt] (neg first handle)(`.u.end;dt)}[;.proc.cd[]] each rdbHandles
  };

.timer.repeat[.proc.cp[];0Wp;.feed.timerperiod;(`.trade.updateRDB;`);"Publish Trade Feed"];

.timer.rep[`timestamp$.proc.cd[]+00:00;0Wp;1D;(`.trade.endofday;`);0h;"Triggering RDB End of Day";1b];

