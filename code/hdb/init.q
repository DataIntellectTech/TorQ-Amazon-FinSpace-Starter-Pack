deleteoldhdb:{[]
	hdbh:first exec w from .servers.SERVERS where proctype=`hdb,not w=0N;
	gateh:exec w from .servers.SERVERS where proctype=`gateway;
	deleteproc:first exec procname from .servers.SERVERS where proctype=`hdb,not w=0N;
	/-Create a list of start times of hdb's, including current process so that list is not empty
	times:.proc.starttimeUTC , @[;".proc.starttimeUTC";()]each hdbh;
	/-If we are the new process, run code
	$[.proc.starttimeUTC = max  times;
		.async.send[0b;;(`.finspace.unregisterfromgw;deleteproc)] each neg[gateh];
		:()];
	};

