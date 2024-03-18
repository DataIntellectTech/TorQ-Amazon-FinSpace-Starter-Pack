//get the relevant rdb attributes (generic partitions)
.proc.getattributes:{`partition`tables!(.rdb.getpartition[],();tables[])}

\d .

upd:$[`daily~.finspace.rollovermode;
    .rdb.upd;
    {[t;x]}];

endofperiod:$[`daily~.finspace.rollovermode;
	endofperiod;
	rolloverendofperiod];
