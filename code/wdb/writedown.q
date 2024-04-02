endofperiod:$[`daily~.finspace.rollovermode;endofperiod;rolloverendofperiod];

/-endofperiod function to savedown by integer
rolloverendofperiod:{[currp;nextp;data]
	.lg.o[`endofperiod;"Received endofperiod. currentperiod, nextperiod and data are ",(string currp),", ", (string nextp),", ", .Q.s1 data];
        /-Obtain handle of any other running wdb's
	h:exec w from .servers.SERVERS where proctype=`wdb,not w=0N;
        /-Create a list of start times of wdb's found from above
	times:@[;".proc.starttimeUTC";()]each h;
	/-If we are the new process, need to set upd to .wdb.upd and set the partition. Otherwise writedown data. WDB doesn't depend on new process being up.
	if[not upd~.wdb.upd;
                /-Setting variables so wdb can become the active wdb for this new period
		@[`.;`upd;:;.wdb.upd];
		.wdb.currentpartition:`long$nextp;
		:()];
        /-We must be old process so unsubscribe from the tp and begin writedown process
	hclose each distinct exec w from .sub.SUBSCRIPTIONS;
	/-Need to download sym file to scratch directory
        .lg.o[`createchangeset;"downloading sym file to scratch directory for ",.finspace.database];
	.aws.get_latest_sym_file[.finspace.database;1_string .wdb.savedir];
	.wdb.savetables[.wdb.savedir;.wdb.currentpartition;1b;] each .wdb.tablelist[];
	/-Create changeset containing data
	.finspace.createchangeset[.finspace.database];
	/-trigger hdb start with trigger log
	$[@[get;`.finspace.rdbready;0b];
		.wdb.checkrdbready[];
		.timer.repeat[.proc.cp[];0Wp;0D00:02;(`.wdb.checkrdbready;`);"set timer to check if newrdb is up"]
	 ];
	};
\d .wdb
endofdaymerge:{[dir;pt;tablist;mergelimits;hdbsettings;mergemethod]
     .lg.o[`merge;"merging on main"];
     reloadsymfile[.Q.dd[hdbsettings `hdbdir;`sym]];
     merge[dir;pt;;mergelimits;hdbsettings;mergemethod] each flip (key tablist;value tablist);
     .lg.o[`eod;"Delete from partsizes"];
     delete from `.merge.partsizes;
     /- if path exists, delete it
     if[not () ~ key savedir;
	     .lg.o[`merge;"deleting temp storage directory"];
	     .os.deldir .os.pth[string[` sv savedir,`$string[pt]]];
	     ];
     /-call the posteod function
     .save.postreplay[hdbsettings[`hdbdir];pt];
     $[permitreload; 
	     doreload[pt];
	     if[gc;.gc.run[]];
	     ];
     };

movetohdb:{[dw;hw;pt]
  $[not(`$string pt)in key hsym`$-10 _ hw;
     .[.os.ren;(dw;hw);{.lg.e[`mvtohdb;"Failed to move data from wdb ",x," to hdb directory ",y," : ",z]}[dw;hw]];
      not any a[dw]in(a:{key hsym`$x}) hw;
      [{[y;x]
        $[not(b:`$last"/"vs x)in key y;
          [.[.os.ren;(x;y);{[x;y;e].lg.e[`mvtohdb;"Table ",string[x]," has failed to copy to ",string[y]," with error: ",e]}[b;y;]];
           .lg.o[`mvtohdb;"Table ",string[b]," has been successfully moved to ",string[y]]];
          .lg.e[`mvtohdb;"Table ",string[b]," was skipped because it already exists in ",string[y]]];
        }[hsym`$hw]'[dw,/:"/",/:string key hsym`$dw];
        if[0=count key hsym`$dw;@[.os.deldir;dw;{[x;y].lg.e[`mvtohdb;"Failed to delete folder ",x," with error: ",y]}[dw]]]];
     .lg.e[`mvtohdb;raze"Table(s) ",string[(key hsym`$hw)inter(key hsym`$dw)]," is present in both location. Operation will be aborted to avoid corrupting the hdb"]]
 }

reloadsymfile:{[symfilepath]
  .lg.o[`sort; "reloading the sym file from: ",string symfilepath];
  @[load; symfilepath; {.lg.e[`sort;"failed to reload sym file: ",x]}]
 }

endofdaysortdate:{[dir;pt;tablist;hdbsettings]
  /-sort permitted tables in database
  /- sort the table and garbage collect (if enabled)
  .lg.o[`sort;"starting to sort data"];
  .lg.o[`sort;"sorting on main sort"];
  reloadsymfile[.Q.dd[hdbsettings `hdbdir;`sym]];
  {[x] .sort.sorttab[x];if[gc;.gc.run[]]} each tablist,'.Q.par[dir;pt;] each tablist;
  .lg.o[`sort;"finished sorting data"];
  /-move data into hdb
  .lg.o[`mvtohdb;"Moving partition from the temp wdb ",(dw:.os.pth -1 _ string .Q.par[dir;pt;`])," directory to the hdb directory ",hw:.os.pth -1 _ string .Q.par[hdbsettings[`hdbdir];pt;`]];
  .lg.o[`mvtohdb;"Attempting to move ",(", "sv string key hsym`$dw)," from ",dw," to ",hw];
  .[movetohdb;(dw;hw;pt);{.lg.e[`mvtohdb;"Function movetohdb failed with error: ",x]}];

  /-call the posteod function
  .save.postreplay[hdbsettings[`hdbdir];pt];
  if[permitreload;
    doreload[pt];
    ];
  };



checkrdbready:{
	if[@[get;`.finspace.rdbready;0b];
	   .lg.o[`.wdb.checkrdbready;"new rdb ready. create new hdb"];
	   .timer.remove @/: exec id from .timer.timer where `.wdb.checkrdbready in' funcparam;
	]
 };
