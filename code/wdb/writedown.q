/-endofperiod function to savedown by integer
endofperiod:{[currp;nextp;data]
	.lg.o[`endofperiod;"Received endofperiod. currentperiod, nextperiod and data are ",(string currp),", ", (string nextp),", ", .Q.s1 data]
        / Need to download sym file to scratch directory if this is Finspace application
        .lg.o[`createchangeset;"downloading sym file to scratch directory for ",.finspace.database];
	.aws.get_latest_sym_file[.finspace.database;1_string .wdb.savedir];
        /- change to integer partition
	.wdb.currentpartition:(`long$currp);
	/-call function to savedown tables
	.wdb.savetables[.wdb.savedir;.wdb.currentpartition;1b;] each .wdb.tablelist[];
	/- create changeset containing data
	changeset:.finspace.createchangeset[.finspace.database];
	/.finspace.notifyhdb[;changeset] each .finspace.hdbclusters;					/-TODO replace this line with hdb start trigger log
        };
