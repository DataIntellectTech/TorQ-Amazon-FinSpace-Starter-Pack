// Params
\d .feed

/ load settings
nq:@[value;`nq;100];                                //number of quotes to generate
nt:@[value;`nt;100];                                //number of trades to generate
randomcounts:@[value;`randomcounts;0.00000001];
rnd:{0.01*floor 100*x};
timerperiod:@[value;`timerperiod;0D00:01:00.000];   //the time interval to push new dummy data to the tp clusters

\d .
// Generates dummy trade, quotes and depth data to be pushed to the tp
.trade.generateData:{[nq;nt;randomcounts]
 syms:`NOK`YHOO`CSCO`ORCL`AAPL`DELL`IBM`MSFT`GOOG;
 srcs:`N`O`L;
 initpxs:syms!20f+count[syms]?30f;
 if[(not -9f=type randomcounts) or not randomcounts within (0;1); '"randomcounts factor should be float within 0 and 1"];
 /- randomize the number of quotes and trades
 nq:`int$nq * 1 + rand[randomcounts]*signum -.5+rand 1f;
 nt:`int$nt * 1 + rand[randomcounts]*signum -.5+rand 1f;
 qts:update px*initpxs sym from update px:exp px from update sums px by sym from update px:0.0005*-1+nq?2f from([]sym:`g#nq?syms;src:`g#nq?srcs);
 qts:select sym,src,bid:.feed.rnd px-nq?0.03,ask:.feed.rnd px+nq?0.03,bsize:"i"$(500*1+nq?20),asize:"i"$(500*1+nq?20) from qts;
 trds:update bid:reverse fills reverse bid,ask:reverse fills reverse ask,bsize:reverse fills reverse bsize,asize:reverse fills reverse asize by sym from aj[enlist[`sym];([]sym:nt?syms;src:nt?srcs;side:nt?`buy`sell);qts];
 trds:select sym,src,price:?[side=`buy;ask;bid],size:`int$(nt?1f)*?[side=`buy;asize;bsize] from trds;

 :(`trades`quotes!(trds;qts));

 };

.trade.upd:{[w;t;d](neg first w)(`upd;t;d)};

.trade.updateTP:{
  tpHandles:exec w from .servers.SERVERS where proctype in `segmentedtickerplant, .dotz.liveh w;
  if[not count tpHandles; .lg.e[`updateTP;"no valid handles amongst subscribers"]; :()];
  tradedata:.trade.generateData[.feed.nq;.feed.nt;.feed.randomcounts];
  tradedata[`trades]:delete from tradedata[`trades] where null price;
  @[{[handle;data].trade.upd[handle;;]'[key data;value data]}[;tradedata];;{0b}] each tpHandles
  };

.servers.startup[];

.timer.repeat[.proc.cp[];0Wp;.feed.timerperiod;(`.trade.updateTP;`);"Publish Trade Feed"];
