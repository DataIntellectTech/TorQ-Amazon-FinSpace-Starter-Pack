/-endofperiod function to savedown by integer
endofperiod:{[currp;nextp;data]
	.lg.o[`endofperiod;"Received endofperiod. currentperiod, nextperiod and data are ",(string currp),", ", (string nextp),", ", .Q.s1 data]
        /-check if there is more than 1 wdb processes
	h:exec w from .servers.SERVERS where proctype=`wdb,not w=0N;
        /-create a dictionary of process names and their start times
	times:raze{@[;".proc.starttimeUTC";()][x]} each h;
	if[.proc.starttimeUTC >max times;
		@[`.;`upd;:;insert];
		.wdb.currentpartition:`long$nextp;
		:()];
	/-If we are the new process, exit function, do not want to writedown
        /-We must be old process so must writedown
	hclose each distinct exec w from .sub.SUBSCRIPTIONS;
	/ Need to download sym file to scratch directory
        .lg.o[`createchangeset;"downloading sym file to scratch directory for ",.finspace.database];
	.aws.get_latest_sym_file[.finspace.database;1_string .wdb.savedir];
	.wdb.savetables[.wdb.savedir;.wdb.currentpartition;1b;] each .wdb.tablelist[];
	/- create changeset containing data
	.finspace.createchangeset[.finspace.database];
	/-TODO add logic to trigger hdb start with trigger log
	};
