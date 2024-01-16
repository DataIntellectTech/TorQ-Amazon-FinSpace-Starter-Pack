
\d .wdb

.finspace.newrdbready:0b; //hard coded value

checknewrdbup:{ 
    if[@[get;`.finspace.newrdbready;0b];
      .lg.o[`checknewrdbup;"kill the hdb!"];
      .timer.remove @/: exec id from .timer.timer where `.wdb.checknewrdbup in' funcparam;
     ]
 };

$[@[get;`.finspace.newrdbready;0b];
   .wdb.checknewrdbup[];
   .timer.repeat[.proc.cp[];0Wp;0D00:02;(`.wdb.checknewrdbup;`);"set timer to check if newrdb is up"]
 ];


