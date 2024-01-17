\d .finspace

database:getenv[`KDBDATABASETRADE];

\d .wdb
savedir:hsym`$getenv[`KDBSCRATCH];  // the location of the hdb directory
hdbdir:hsym`$getenv[`KDBSCRATCH];
sortworkertypes:()
replay:0b;
upd:(::);

\d .servers
CONNECTIONS:`hdb`tickerplant`rdb`gateway`sort`wdb


