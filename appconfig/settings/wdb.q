\d .finspace

database:getenv[`KDBDATABASETRADE];

\d .wdb
savedir:hsym`$getenv[`KDBSCRATCH];  // the location of the hdb directory
hdbdir:hsym`$getenv[`KDBSCRATCH];

