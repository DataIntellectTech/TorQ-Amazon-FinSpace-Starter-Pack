opts:.Q.opt .z.x;

setenv[`KDBDATABASETRADE; .aws.akdb];

codeDir:$[`codeDir in key opts; first opts`codeDir; .aws.akcp ];
hdbDir:$[`hdbDir in key opts; first opts`hdbDir; .aws.akdbp, "/", getenv `KDBDATABASETRADE];

torqDir:codeDir,"/TorQ";
appDir:codeDir,"/TorQ-Amazon-FinSpace-Starter-Pack";

sharedVolume:string first key `:/opt/kx/app/shared;

setenv[`TORQHOME; torqDir];
setenv[`TORQAPPHOME; appDir];

setenv[`KDBCODE; torqDir,"/code"];
setenv[`KDBCONFIG; torqDir,"/config"];
setenv[`KDBLOG; torqDir,"/logs"];
setenv[`KDBHTML; torqDir,"/html"]
setenv[`KDBLIB; torqDir,"/lib"];
setenv[`KDBHDB; hdbDir];
setenv[`KDBDATAVIEW;"finspace-dataview"];     // [ "" | "finspace-dataview" ] - TODO. Make the dataview name not be hard-coded.


setenv[`KDBSCRATCH; "/opt/kx/app/scratch"];
// check if we are using a scaling group and not a dedicated cluster
// scratch dir doesn't exist when using scaling groups
if[()~key hsym`$getenv[`KDBSCRATCH];
    // dirs are /common and /clustername of each cluster in the volume
    setenv[`KDBSCRATCH; "/opt/kx/app/shared/",sharedVolume,"/",first .aws.args[`procname]]];

setenv[`KDBFINSPACE; "true"];

setenv[`KDBAPPCONFIG; appDir,"/appconfig"];
setenv[`KDBAPPCODE; appDir,"/code"];

setenv[`KDBBASEPORT; "17000"];
setenv[`KDBSTACKID; "-stackid ",getenv`KDBBASEPORT];
setenv[`TORQPROCESSES; getenv[`KDBAPPCONFIG],"/process.csv"];

/ TODO - remove this once we can pass in the env file as a cmd line parameter
system"l ",torqDir,"/torq.q";
