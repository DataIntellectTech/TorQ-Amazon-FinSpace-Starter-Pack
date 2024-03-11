// Segmented TP config

\d .stplg
  
multilogperiod:0D02;            // Length of period for STP periodic logging modes
errmode:0b;                     // Enable error mode for STP
batchmode:`immediate;           // [memorybatch|defaultbatch|immediate]
replayperiod:`period            // [period|day|prior]
kdbtplog:.aws.tp_log_path;

\d .proc
params[`schemafile]:.finspace.schemafilepath;

\d .hb
enabled:1b;                     // enbable heartbeating to keep finspace connections alive
