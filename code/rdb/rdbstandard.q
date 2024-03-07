//get the relevant rdb attributes (int partition)
.proc.getattributes:{`int`tables!(.rdb.getpartition[],();tables[])}

\d .

upd:$[`daily~.finspace.rollovermode;
    .rdb.upd;
    {[t;x]}];
