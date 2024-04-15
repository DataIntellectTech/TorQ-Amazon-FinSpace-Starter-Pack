\d .

upd:$[`daily~.finspace.rollovermode;
    .rdb.upd;
    {[t;x]}];

endofperiod:$[`daily~.finspace.rollovermode;
	endofperiod;
	rolloverendofperiod];
