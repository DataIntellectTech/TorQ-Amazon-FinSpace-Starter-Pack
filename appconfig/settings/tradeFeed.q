//TODO this can be changed or removed to work with discovery once unblocked
.feed.clusters:enlist `$"rdb"

\d .servers

CONNECTIONS:enlist `gateway         // if connectonstart false, include tickerplant in tickerplanttypes, not in CONNECTIONS
