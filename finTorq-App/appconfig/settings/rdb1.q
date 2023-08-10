position:([]sym:`g#`symbol$();quantity:`long$();price:`float$();currency:`symbol$());
rates:([]sym:`g#`symbol$();rate:`float$();currency:`symbol$());

.rdb.database:getenv[`KDBDATABSE];

.aws.get_latest_sym_file[getenv[`KDBDATABSE];getenv[`KDBSCRATCH]];

