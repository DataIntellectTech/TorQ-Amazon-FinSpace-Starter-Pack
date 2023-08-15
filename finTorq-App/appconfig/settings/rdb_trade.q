depth:([]sym:`g#`symbol$();time:`timestamp$();bid1:`float$();bsize1:`float$();bid2:`int$();bsize2:`float$();bid3:`int$();bsize3:`int$();ask1:`float$();asize1:`int$();ask2:`float$();asize2:`int$();ask3:`float$();asize3:`int$());

quotes:([]sym:`g#`symbol$();time:`timestamp$();src:`symbol$();bid:`float$();ask:`float$();bsize:`int$();asize:`int$());

trades:([]sym:`g#`symbol$();time:`timestamp$();src:`symbol$();price:`float$();size:`int$());

setenv[`KDBHDB;getenv[`KDBHDBTRADE]];

.rdb.database:getenv[`KDBDATABASETRADE];

.aws.get_latest_sym_file[.rdb.database;getenv[`KDBSCRATCH]];

