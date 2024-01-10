getFullPath:{[path]
  if[0~count path;:()];
  if[0h~type path;
    $[all 10h=type each path;:{x where {not x~()}each x}getFullPath each path;'wrongtype]
  ];
  if[not 10h~type path;'wrongtype];

  :@[{first system"readlink -f '",x,"'"};path;
    {[x;y] -2"ERROR: Could not find path to: '",x,"'";exit 1}[path]];
 };

MAIN_SCRIPT_DIR:{("/" sv -1 _ "/" vs x),"/"}getFullPath string .z.f;  // Used this so that the script will load its dependencies correctly even if the user starts the script form another directory

system"l ",MAIN_SCRIPT_DIR,"compatibility_scanner/zs_regex.q";
system"l ",MAIN_SCRIPT_DIR,"compatibility_scanner/show_help.q";

DEBUG_SHOW_REGEX_PASSED:0b;

BASH_GREP_SCRIPT:MAIN_SCRIPT_DIR,"compatibility_scanner/grep.sh";
BASH_FIND_SCRIPT:MAIN_SCRIPT_DIR,"compatibility_scanner/find.sh";

ASSIGNMENT_CHECKS_TSV:MAIN_SCRIPT_DIR,"compatibility_scanner/assignment_checks.tsv";
COMMANDS_CHECKS_TSV:MAIN_SCRIPT_DIR,"compatibility_scanner/commands_checks.tsv";


run:{[]
  args:parseArgs[];
  checks:loadChecks[];

  args[`file]:$[
    args`regex;getFilesFromRegex[args`file;args`dir];
    {x where x like "*[.]q"}getFullPath args`file
  ];
  args[`exclude]:$[
    args`regex;getFilesFromRegex[args`exclude;args`dir];
    {x where x like "*[.]q"}getFullPath args`exclude
  ];
  if[10h~type args`dir;  // Checking directory exists if dir argument was passed, if not exits with an error
    isInvalidDir:(()~args`dir)or @[{11h<>type key hsym`$x};args`dir;1b];
    if[isInvalidDir;-2"ERROR: Directory '",args[`dir],"' could not be found";exit 1];
  ];

  if[not ()~args`dir;args[`file]:distinct args[`file],getDirFileList args`dir];
  if[0<count args`file;args[`file]:filterExcluded[args`file;args`exclude]];
  
  res:$[
    0<>count args`file;[
      -1"Scanning ",string[count args`file]," .q script(s) . . .\n";
      sum scanFile[;checks] each args[`file]
    ];
    [-1"No files to scan";0]
  ];

  -1"\nChecked ",string[count args`file]," .q script(s)";
  -1"Total lines with possible incompatibilities: ",string res;

  exit 0;
 };

getFilesFromRegex:{[regexList;dir]
  if[0~count regexList;:()];

  if[dir~();dir:first system"pwd"];
  res:raze{system"find ",x," -regextype posix-extended -type f -regex ","'",y,"'"}[dir]each regexList;

  :res where res like "*[.]q";
 };

scanFile:{[file;checks]
  if[not {(1~count x) and -11h~type x}key hsym`$file;
    -2"ERROR: No file at location '",file,"'";
    exit 1;
  ];

  res:system"bash ",BASH_GREP_SCRIPT," '",checks,"' \"",file,"\"";
  if[""~raze/[res];res:()];
  if[0<count res;-1"\n" sv res];

  :count res;
 };

getDirFileList:{[dir]
  :system"bash ",BASH_FIND_SCRIPT," \"",dir,"\"";
 };

parseArgs:{[]
  if[$[0<>count .z.x;"--help" in .z.x;0b] or 0~count .z.x;showHelp[]];

  args:(enlist[`]!enlist[::]),.Q.opt .z.x;

  if[0h~type args`dir;args[`dir]:first args`dir];
  if[10h<>type args`dir;args[`dir]:()];

  if[0h<>type args`file;args[`file]:enlist args`file];
  args[`file]:args[`file] where 10h=type each args`file;

  if[0h<>type args`exclude;args[`exclude]:enlist args`exclude];
  args[`exclude]:args[`exclude] where 10h=type each args`exclude;

  args[`regex]:$[0<>count .z.x;"--regex" in .z.x;0b];

  :args;
 };

loadChecks:{[]
  checksList:readAssignmentChecks ASSIGNMENT_CHECKS_TSV;
  checksList,:readCommandsChecks COMMANDS_CHECKS_TSV;

  res:-1 _ raze{"(",x,")|"}each checksList;

  if[DEBUG_SHOW_REGEX_PASSED;"DEBUG: Regex pattern being passed:";-1 res];

  :res;
 };

readCommandsChecks:{[file]
  tbl:("**";enlist"\t") 0: hsym`$file;

  :tbl`regex;
 };

readAssignmentChecks:{[file]
  tbl:("**";enlist"\t") 0: hsym`$file;

  :raze{
    :enlist[y] cross x cross enlist z;
  }[ZS_REGEX]'[tbl`prefix;tbl`suffix];
 };

filterExcluded:{[files;excludedFiles]
  :files where not files in excludedFiles;
 };

run[];
