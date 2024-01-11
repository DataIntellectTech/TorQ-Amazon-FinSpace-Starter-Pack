\d .finspace

database:getenv[`KDBDATABASETRADE];
hdbclusters:enlist `$"hdb";

notifyhdb:{[h;d]
        /-if you can connect to the hdb - call the reload function
        @[h;hdbmessage[d];{.lg.e[`notifyhdb;"failed to send reload message to hdb on handle: ",x]}];
        };

hdbmessage:{[d] (`reload;d)}

\d .wdb
savedir:hsym`$getenv[`KDBSCRATCH];  // the location of the hdb directory
hdbdir:hsym`$getenv[`KDBSCRATCH];

