SCRIPT_DIR:{$["/"~last x;x;x,"/"]}first[system"pwd"],"/","/" sv -1 _ "/" vs string .z.f;
BASH_HELPER_SCRIPT:SCRIPT_DIR,"compatibility_scanner.sh";

overridedZsRegex:(
  "\\.z\\.ts";
  "\\.z\\.pg";
  "\\.z\\.ps";
  "\\.z\\.po";
  "\\.z\\.pc";
  "\\.z\\.ws";
  "\\.z\\.wo";
  "\\.z\\.wc";
  "\\.z\\.pi";
  "\\.z\\.exit"
 );


run:{[]
  args:parseArgs[];
  if[not ()~args`dir;args[`files]:distinct args[`files],getDirFileList args`dir];
  res:$[0<>count args`files;scanFile each args[`files];[-1"No files to scan";()]];

  exit 0;
 };

scanFile:{[file]
  -1"--- '",file,"' ---";

  str:-1 _ raze{"(",x,")|"}each overridedZsRegex;

  res:system"bash ",BASH_HELPER_SCRIPT," \"",str,"\" \"",file,"\"";
  res:{{("J"$first x;":" sv 1 _ x)}":" vs x}each res;
  
  {-1"Line ",string[first x],":\t",last x}each res;

  -1"\nFound ",string[count res]," lines with compatibility issues in file";
 };

getDirFileList:{[dir]
  show key hsym`$dir;

  :();
 };

parseArgs:{[]
  args:(enlist[`]!enlist[::]),.Q.opt .z.x;

  if[0h~type args`dir;args[`dir]:first args`dir];
  if[10h<>type args`dir;args[`dir]:()];

  if[0h<>type args`files;args[`files]:enlist args`files];
  args[`files]:args[`files] where 10h=type each args`files;

  :args;
 };

run[];
