//TODO this can be changed or removed to work with discovery once unblocked
.feed.clusters:enlist `$"rdb1";
.trade.rdbHandles:();

\d .servers

CONNECTIONS:enlist `gateway`rdb         // if connectonstart false, include tickerplant in tickerplanttypes, not in CONNECTIONS
