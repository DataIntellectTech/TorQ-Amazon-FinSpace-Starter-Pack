/-endofperiod function to savedown by integer
endofperiod:{[currp;nextp;data]
	.lg.o[`endofperiod;"Received endofperiod. currentperiod, nextperiod and data are ",(string currp),", ", (string nextp),", ", .Q.s1 data]
	/ Need to download sym file to scratch directory
        .lg.o[`createchangeset;"downloading sym file to scratch directory for ",.finspace.database];
	.aws.get_latest_sym_file[.finspace.database;1_string .wdb.savedir];
	.wdb.currentpartition:`long$currp;
	.wdb.savetables[.wdb.savedir;.wdb.currentpartition;1b;] each .wdb.tablelist[];
	/- create changeset containing data
	.finspace.createchangeset[.finspace.database];
	/-TODO add logic to trigger hdb start with trigger log
        };
