opts:.Q.opt .z.x;
codeDir:$[`codeDir in key opts; first opts`codeDir; "/opt/kx/app/code"];
hdbDir:$[`hdbDir in key opts; first opts`hdbDir; "/opt/kx/app/db"];

torqDir:codeDir,"/TorQ";
appDir:codeDir,"/finTorq-App";


setenv[`TORQHOME; torqDir];
setenv[`TORQAPPHOME; appDir];

setenv[`KDBCODE; torqDir,"/code"];
setenv[`KDBCONFIG; torqDir,"/config"];
setenv[`KDBLOG; torqDir,"/logs"];
setenv[`KDBHTML; torqDir,"/html"]
setenv[`KDBLIB; torqDir,"/lib"];
setenv[`KDBHDBPOSITION; hdbDir,"/oreganTestDatabase"];
setenv[`KDBHDBTRADE; hdbDir,"/oreganTradeDatabase"];
setenv[`KDBSCRATCH; "/opt/kx/app/scratch"];
setenv[`KDBDATABASEPOSITION; "oreganTestDatabase"];
setenv[`KDBDATABASETRADE; "oreganTradeDatabase"];

setenv[`KDBAPPCONFIG; appDir,"/appconfig"];
setenv[`KDBAPPCODE; appDir,"/code"];

setenv[`KDBBASEPORT; "17000"];
setenv[`KDBSTACKID; "-stackid ",getenv`KDBBASEPORT];
setenv[`TORQPROCESSES; getenv[`KDBAPPCONFIG],"/process.csv"];

/ TODO - remove this once we can pass in the env file as a cmd line parameter
system"l ",torqDir,"/torq.q";

/ system"l ",torqDir,"/code/processes/rdb.q";
