\d .wdb
startup:{[f]
	f[]; /-Call the original startup function
	@[`.;`upd;:;{[t;x]}]; 
	};[startup]

