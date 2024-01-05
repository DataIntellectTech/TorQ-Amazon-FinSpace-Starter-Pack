/-endofperiod function to savedown by integer
endofperiod:{[currp;nextp;data]
        .lg.o[`endofperiod;"Received endofperiod. currentperiod, nextperiod and data are ",(string currp),", ", (string nextp),", ", .Q.s1 data]
        /- change to integer partition
        / Need to download sym file to scratch directory if this is Finspace application
        .lg.o[`createchangeset;"downloading sym file to scratch directory for ",.finspace.database];
	.aws.get_latest_sym_file[.finspace.database;getenv[`KDBSCRATCH]];
        /- change to integer partition
        .wdb.currentpartition:(`long$currp);
        .wdb.savetables[.wdb.savedir;.wdb.currentpartition;1b;] each .wdb.tablelist[];
        /-TODO May need to add merge function from eod to save to HDB, currently saves to WDBHDB
        changeset:.finspace.createchangeset[.finspace.database];
	.finspace.notifyhdb[;changeset] each .finspace.hdbclusters;
        };
