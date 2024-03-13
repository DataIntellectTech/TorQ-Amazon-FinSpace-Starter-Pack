// Segmented TP config

\d .stplg
multilogperiod:0D02;            // Length of period for STP periodic logging modes
kdbtplog:.aws.tp_log_path;

\d .proc
params[`schemafile]:enlist getenv[`TORQAPPHOME],"/database.q";

\d .hb
enabled:1b;                     // enbable heartbeating to keep finspace connections alive
