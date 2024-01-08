MAIN_SCRIPT_DIR:{$["/"~last x;x;x,"/"]}first[system"pwd"],"/","/" sv -1 _ "/" vs string .z.f;

BASH_GREP_SCRIPT:MAIN_SCRIPT_DIR,"compatibility_scanner/grep.sh";
BASH_FIND_SCRIPT:MAIN_SCRIPT_DIR,"compatibility_scanner/find.sh";

ASSIGNMENT_CHECKS_TSV:MAIN_SCRIPT_DIR,"compatibility_scanner/assignment_checks.tsv";
COMMANDS_CHECKS_TSV:MAIN_SCRIPT_DIR,"compatibility_scanner/commands_checks.tsv";

ZS_REGEX:(
  "\\.z\\.a";
  "\\.z\\.b";
  "\\.z\\.c";
  "\\.z\\.d";
  "\\.z\\.D";
  "\\.z\\.e";
  "\\.z\\.ex";
  "\\.z\\.ey";
  "\\.z\\.f";
  "\\.z\\.H";
  "\\.z\\.h";
  "\\.z\\.i";
  "\\.z\\.K";
  "\\.z\\.k";
  "\\.z\\.l";
  "\\.z\\.n";
  "\\.z\\.N";
  "\\.z\\.o";
  "\\.z\\.p";
  "\\.z\\.P";
  "\\.z\\.pm";
  "\\.z\\.q";
  "\\.z\\.s";
  "\\.z\\.t";
  "\\.z\\.T";
  "\\.z\\.u";
  "\\.z\\.w";
  "\\.z\\.W";
  "\\.z\\.x";
  "\\.z\\.X";
  "\\.z\\.z";
  "\\.z\\.Z";
  "\\.z\\.zd";
  "\\.z\\.ac";
  "\\.z\\.bm";
  "\\.z\\.exit";
  "\\.z\\.pc";
  "\\.z\\.pd";
  "\\.z\\.pg";
  "\\.z\\.ph";
  "\\.z\\.pi";
  "\\.z\\.po";
  "\\.z\\.pp";
  "\\.z\\.pq";
  "\\.z\\.r";
  "\\.z\\.ps";
  "\\.z\\.pw";
  "\\.z\\.ts";
  "\\.z\\.vs";
  "\\.z\\.wc";
  "\\.z\\.wo";
  "\\.z\\.ws"
 );


run:{[]
  args:parseArgs[];

  if[not ()~args`dir;args[`files]:distinct args[`files],getDirFileList args`dir];
  if[0<count args`files;args[`files]:filterExcluded[args`files;args`exclude]];
  checks:loadChecks[];

  res:$[0<>count args`files;sum scanFile[;checks] each args[`files];[-1"No files to scan";0]];

  -1"\nChecked ",string[count args`files]," .q script(s)";
  -1"Total lines with incompatibilities: ",string res;

  exit 0;
 };

scanFile:{[file;checks]
  if[not {(1~count x) and -11h~type x}key hsym`$file;
    -2"ERROR: No file at location '",file,"'";
    :0;
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
  args:(enlist[`]!enlist[::]),.Q.opt .z.x;

  if[0h~type args`dir;args[`dir]:first args`dir];
  if[10h<>type args`dir;args[`dir]:()];

  if[0h<>type args`files;args[`files]:enlist args`files];
  args[`files]:args[`files] where 10h=type each args`files;

  if[0h<>type args`exclude;args[`exclude]:enlist args`exclude];
  args[`exclude]:args[`exclude] where 10h=type each args`exclude;

  :args;
 };

loadChecks:{[]
  checksList:readAssignmentChecks ASSIGNMENT_CHECKS_TSV;
  checksList,:readCommandsChecks COMMANDS_CHECKS_TSV;

  :-1 _ raze{"(",x,")|"}each checksList;
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
