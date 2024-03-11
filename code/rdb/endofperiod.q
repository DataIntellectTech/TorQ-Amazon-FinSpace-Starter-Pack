/-endofperiod function
rolloverendofperiod:{[currp;nextp;data] 
	.lg.o[`endofperiod;"Received endofperiod. currentperiod, nextperiod and data are ",(string currp),", ", (string nextp),", ", .Q.s1 data];
	/-Obtain handle of any other running rdb's
	h:exec w from .servers.SERVERS where proctype=`rdb,not w=0N;
	/-Create a list of start times of rdb's,m including current process so that list is not empty
	times:.proc.starttimeUTC , @[;".proc.starttimeUTC";()]each h;
	/-If we are the new process, exit function, do not want to close handle
	if[.proc.starttimeUTC = max times;
		/-Setting variables so rdb can become the active rdb for this new period
		.rdb.rdbpartition:`long$nextp;
		/-send message to gateways to update the rdb attributes
		gateh:exec w from .servers.getservers[`proctype;.rdb.gatewaytypes;()!();0b;0b];
                .async.send[0b;;(`setattributes;.proc.procname;.proc.proctype;.proc.getattributes[])] each neg[gateh];
		@[`.;`upd;:;.rdb.upd];
                :()];
	/-We must be old process so unsubscribe from the tp and set upd to null
	hclose each distinct exec w from .sub.SUBSCRIPTIONS;
	/-RDB remains idle to serve client queries
        };
