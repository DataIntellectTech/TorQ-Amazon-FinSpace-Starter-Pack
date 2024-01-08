.z.ts:{};
.z.pg  :   {};
`.z.ps set {};

set[`.z.po]  {};
set .z.pc
set `.z.pg
.set `.z.pc
abc.set `.z.pg
preset `.z.pi

.z.ws set abc;
.z.wo  set  {}


.z.wc
.z.pi    :    {}

.z.ts:{}

\p 1234
system"p 1234"

system"p"
system"p     "
system"p 0W"

-1"test";\p 1234;

system"p ",string 10

.z.zd:loadparams`compression];
@[system;"x .z.zd";()];
.z.pp:{[f;x]$[(`$"X-Grafana-Org-Id")in key last x;zpp;f]x}[@[value;`.z.pp;{{[x]}}]];
.z.ph:{[f;x]
.z.pc:{if[y;.hb.subscribedhandles::.hb.subscribedhandles except y]; x@y}@[value;`.z.pc;{{[x]}}];
if[.z.K >= 3.3;.z.wc:close[`.z.wc]; .z.pc:close[`.z.pc]]
.z.ws:{neg[.z.w] -8!.j.j[.html.evaluate[.j.k -9!x]];}
.z.pc:{[f;x] @[f;x;()];.stpps.closesub x} @[value;`.z.pc;{{}}];
.z.pc:{.sub.pc[x y;y]}@[value;`.z.pc;{[x]}];
.z.ts:{[x;y] .timer.run now:.proc.cp[]; x@y}[.z.ts];
.z.ts:{if[.proc.cp[]>.timer.nextruntime;.timer.run[.proc.cp[]]]}];
.z.ts:run
del:{w[x]_:w[x;;0]?y};.z.pc:{del[;x]each t};
.z.ps:{x@y;.kxdash.dashps y}@[value;`.z.ps;{{value x}}];
.z.pw:{$[.access.vpw[y;z];x[y;z];0b]}.z.pw;
.z.pg:{$[.access.vpg[y];.access.validsize[;`pg.size;y]x y;.access.invalidpt y]}.z.pg;
.z.ps:{$[.access.vps[y];x y;.access.invalidpt y]}.z.ps;
.z.ws:{$[.access.vws[y];x y;.access.invalidpt y]}.z.ws;
.z.pi:{$[.access.vpi[y];x y;.access.invalidpt y]}.z.pi;
.z.ph:{$[.access.vph[y];x y;.h.hn["403 Forbidden";`txt;"Forbidden"]]}.z.ph;
.z.pp:{$[.access.vpp[y];x y;.h.hn["403 Forbidden";`txt;"Forbidden"]]}.z.pp]];
.dotz.pw.ORIG:.z.pw:@[.:;`.z.pw;{{[x;y]1b}}];
.dotz.po.ORIG:.z.po:@[.:;`.z.po;{;}];
.dotz.pc.ORIG:.z.pc:@[.:;`.z.pc;{;}];
.dotz.wo.ORIG:.z.wo:@[.:;`.z.wo;{;}];
.dotz.wc.ORIG:.z.wc:@[.:;`.z.wc;{;}];
.dotz.exit.ORIG:.z.exit:@[.:;`.z.exit;{;}];
.dotz.pg.ORIG:.z.pg:@[.:;`.z.pg;{.:}];
.dotz.ps.ORIG:.z.ps:@[.:;`.z.ps;{.:}];
.dotz.pi.ORIG:.z.pi:@[.:;`.z.pi;{{.Q.s value x}}];
.dotz.pp.ORIG:.z.pp:@[.:;`.z.pp;{;}]; / (poststring;postbody)
.dotz.ws.ORIG:.z.ws:@[.:;`.z.ws;{{neg[.z.w]x;}}]; / default is echo
revert:{.z.pw:.dotz.pw.ORIG;.z.po:.dotz.po.ORIG;.z.pc:.dotz.pc.ORIG;.z.pg:.dotz.pg.ORIG;.z.ps:.dotz.ps.ORIG;.z.pi:.dotz.pi.ORIG;.z.ph:.dotz.ph.ORIG;.z.pp:.dotz.pp.ORIG;.z.ws:.dotz.ws.ORIG;.dotz.SAVED.ORIG:0b;.z.exit:.dotz.exit.ORIG;}
.z.pw:{all(.ldap.login;x).\:(y;z)}@[value;`.z.pw;{{[x;y]1b}}];  / redefine .z.pw
.z.pw:p0[`pw;.z.pw;;];
.z.po:p1[`po;.z.po;];.z.pc:p1[`pc;.z.pc;];
.z.wo:p1[`wo;.z.wo;];.z.wc:p1[`wc;.z.wc;];
.z.ws:p2[`ws;.z.ws;];.z.exit:p2[`exit;.z.exit;];
.z.pg:p2[`pg;.z.pg;];.z.pi:p2[`pi;.z.pi;];
.z.ph:p2[`ph;.z.ph;];.z.pp:p2[`pp;.z.pp;];
.z.ps:p3[`ps;.z.ps;];]
.z.ps:{@[x;(`.pm.req;y)]}.z.ps;
.z.pg:{@[x;(`.pm.req;y)]}.z.pg;
.z.pi:{$[x in (1#"\n";"");.Q.s value x;.Q.s $[.z.w=0;value;req]@x]};
.z.pp:{'"pm: HTTP POST requests not permitted"};
$[(.z.K>=3.5)&.z.k>=2019.11.13;.h.val:req;.z.ph:{'"pm: HTTP GET requests not permitted"}];
.z.ws:{'"pm: websocket access not permitted"};
.z.pw:login;
.z.pc:{droppublic[y];@[x;y]}.z.pc;
.z.pc:{.clients.pc[x y;y]}.z.pc;
.z.po:{.clients.po[x y;y]}.z.po;
.z.wo:{.clients.wo[x y;y]}.z.wo;
.z.wc:{.clients.pc[x y;y]}.z.wc;
.z.pg:{.clients.hit[@[x;y;.clients.hite]]}.z.pg;
.z.ps:{.clients.hit[@[x;y;.clients.hite]]}.z.ps;
.z.ws:{.clients.hit[@[x;y;.clients.hite]]}.z.ws;]];
.z.ts:{.clients.cleanup[]};
.z.pc:{.servers.pc[x y;y]}.z.pc;
.z.pg:{[x;y] $[10h=type y;reval(x;y); x y]}.z.pg;
.z.ps:{[x;y] $[10h=type y;reval(x;y); x y]}.z.ps;	
.z.ws:{[x;y] $[10h=type y;reval(x;y); x y]}.z.ws;	
.z.ph:{[x] .h.hn["403 Forbidden";`txt;"Forbidden"]};	
.z.pp:{[x] .h.hn["403 Forbidden";`txt;"Forbidden"]};	
.z.ps:{$[any first[y]~/:ignorelist;value y;x @ y]}[@[value;`.z.ps;{value}]]]
.z.pc:{[x;y]  
.z.pc:{subs::(enlist y) _ subs; x@y}@[value;`.z.pc;{;}]
.z.pc:{x@y;.gw.pc[y]}@[value;`.z.pc;{{[x]}}];
.z.po:{x@y;.gw.po[y]}@[value;`.z.po;{{[x]}}];
.z.pg:{.gw.pgs[.z.w;1b];x@y}@[value;`.z.pg;{{[x]}}];
.z.ps:{.gw.pgs[.z.w;0b];x@y}@[value;`.z.ps;{{[x]}}];
if[@[{value x;1b};`.z.ws;{0b}];.z.ws:{.gw.pgs[.z.w;0b];x@y}.z.ws];
.z.pc:{if[y;subscribedhandles::subscribedhandles except y]; x@y}@[value;`.z.pc;{{[x]}}]
.z.exit:{[x;y] saveconfig[.monitor.configstored;checkconfig];x@y}[@[value;`.z.exit;{{[x]}}]]
.z.ts:.stpps.zts[chainmode];
.z.zd:compression;
.z.ts:{pub'[t;value each t];@[`.;t;@[;`sym;`g#]0#];i::j;icounts::jcounts;ts .z.p};
.z.ts:{ts .z.p};
.z.pd:{$[.z.K<3.3;
.z.zd:compression
.z.ts:{@[{t:``pos _ select from .Q.prf0 p where not .Q.fqk each file;
$[null p:"I"$.z.x 0;[system"p 0W";.z.pg:{p::x;system"p 0";system"t 10"};system qcmd," "sv string[(.z.f;"j"$system"p")],.z.x];system"t 10"]
.z.pc:{[f;x]
.z.exit:{
.z.ts:{pub'[t;value each t];@[`.;t;@[;`sym;`g#]0#];i::j;ts .z.D};
.z.ts:{ts .z.D};
del:{w[x]_:w[x;;0]?y};.z.pc:{del[;x]each t};
.z.ts:run
.z.pi:{.Q.s value x};]