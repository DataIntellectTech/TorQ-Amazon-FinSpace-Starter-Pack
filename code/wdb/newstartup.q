\d .wdb
/Ignorme set so function doesnt run immediately
startup:{[f;ignoreme]
	f[]; /-Call the original startup function
	@[`.;`upd;:;{[t;x]}]; 
	}[startup]

