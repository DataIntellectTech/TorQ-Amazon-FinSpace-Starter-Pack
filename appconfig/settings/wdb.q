// wdb is designed to be 1:1 relationship periods.Therefore every new period will have a new wdb.
.proc.loadprocesscode:1b;

\d .wdb
replay:0b;     // We don't want to replay as the wdb will start before the period it is meant to subscribe to
upd:{[t;x]};   //Discard data until the end of period signals the start of new period

