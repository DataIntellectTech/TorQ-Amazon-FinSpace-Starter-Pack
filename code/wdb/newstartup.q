\d .wdb
/Ignoreme set so function doesnt run immediately
startup:{[f;ignoreme]
	f[]; /-Call the original startup function
	$[`daily~.finspace.rollovermode;
		@[`.;`upd;:;.wdb.upd];
		@[`.;`upd;:;{[t;x]}]
                ];
	}[startup]

