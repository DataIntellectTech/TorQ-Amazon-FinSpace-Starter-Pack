/-endofperiod function to savedown by integer
endofperiod:{[currp;nextp;data]
	.lg.o[`endofperiod;"Received endofperiod. currentperiod, nextperiod and data are ",(string currp),", ", (string nextp),", ", .Q.s1 data];
        /-Obtain handle of any other running wdb's
	h:exec w from .servers.SERVERS where proctype=`wdb,not w=0N;
        /-Create a list of start times of wdb's found from above
	times:@[;".proc.starttimeUTC";()]each h;
	/-If we are the new process, need to set upd to .wdb.upd and set the partition. Otherwise writedown data. WDB doesn't depend on new process being up.
	if[not upd~.wdb.upd;
                /-Setting variables so wdb can become the active wdb for this new period
		@[`.;`upd;:;.wdb.upd];
		.wdb.currentpartition:`long$nextp;
		:()];
        /-We must be old process so unsubscribe from the tp and begin writedown process
	hclose each distinct exec w from .sub.SUBSCRIPTIONS;
	/-Need to download sym file to scratch directory
        .lg.o[`createchangeset;"downloading sym file to scratch directory for ",.finspace.database];
	.aws.get_latest_sym_file[.finspace.database;1_string .wdb.savedir];
	.wdb.savetables[.wdb.savedir;.wdb.currentpartition;1b;] each .wdb.tablelist[];
	/-Create changeset containing data
	.finspace.createchangeset[.finspace.database];
	/-TODO add logic to trigger hdb start with trigger log
	};
