// when rollovermode=`period wdb is designed to be 1:1 relationship with periods.Therefore every new period will have a new wdb.
\d .wdb
replay:.finspace.rollovermode<>`period;         // if in rollovermode=`period turn off tp log replay
                                                // as we don't want the current period, we want the next one

savedir:hsym`$getenv[`KDBSCRATCH];              // the location of the hdb directory
hdbdir:hsym`$getenv[`KDBSCRATCH];

\d .finspace
database:getenv[`KDBDATABASETRADE];
