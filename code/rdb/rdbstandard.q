//get the relevant rdb attributes (int partition)
.proc.getattributes:{`int`tables!(.rdb.getpartition[],();tables[])}

\d .
upd:{[t;x]};
