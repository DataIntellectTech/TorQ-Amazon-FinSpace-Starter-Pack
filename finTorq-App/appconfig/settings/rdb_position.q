position:([]sym:`g#`symbol$();quantity:`long$();price:`float$();currency:`symbol$());
rates:([]sym:`g#`symbol$();rate:`float$();currency:`symbol$());

setenv[`KDBHDB;getenv[`KDBHDBPOSITION]];

.rdb.database:getenv[`KDBDATABASEPOSITION];

.aws.get_latest_sym_file[.rdb.database;getenv[`KDBSCRATCH]];

