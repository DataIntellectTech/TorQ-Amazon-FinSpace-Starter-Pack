// Segmented TP config

\d .stplg
multilogperiod:0D02;            // Length of period for STP periodic logging modes
kdbtplog:.aws.tp_log_path;

\d .proc
loadcommoncode:1b;              // Needed to load timer
params[`schemafile]:enlist getenv[`TORQAPPHOME],"/database.q";

// enable the below variables so heartbeating can keep finspace connections alive
.servers.enabled:1b;
.timer.enabled:1b;
.hb.enabled:1b;
.servers.STARTUP:1b;
