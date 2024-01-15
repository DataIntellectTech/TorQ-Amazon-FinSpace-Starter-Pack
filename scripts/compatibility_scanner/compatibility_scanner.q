DEBUG_SHOW_REGEX_PASSED:0b;

ZS_TO_CHECK:(  // .z functions to look out for without the ".z." prefix attached
  "pm";
  "zd";
  "ac";
  "bm";
  "exit";
  "pc";
  "pd";
  "pg";
  "ph";
  "pi";
  "po";
  "pp";
  "pq";
  "ps";
  "pw";
  "ts";
  "vs";
  "wc";
  "wo";
  "ws"
 );

getFullPath:{[path]
  if[0~count path;:()];
  if[0h~type path;
    $[all 10h=type each path;:{x where {not x~()}each x}getFullPath each path;
      [-2"ERROR: Wrong type for 'path': ",-3!type path;'wrongtype]];
  ];
  if[not 10h~type path;-2"ERROR: Wrong type for 'path': ",-3!type path;'wrongtype];

  :@[{first system"readlink -f '",x,"'"};path;
    {[x;y] -2"ERROR: Could not find path to '",x,"' due to:\n",y;exit 1}[path]];
 };

MAIN_SCRIPT_DIR:{("/" sv -1 _ "/" vs x),"/"}getFullPath string .z.f;  // Used this so that the script will load its dependencies correctly even if the user starts the script from another directory

ASSIGNMENT_CHECKS_TSV:MAIN_SCRIPT_DIR,"assignment_checks.tsv";
COMMANDS_CHECKS_TSV:MAIN_SCRIPT_DIR,"commands_checks.tsv";


run:{[]
  args:parseArgs[];
  checksDict:loadChecksDict[];

  args[`file]:$[
    args`regex;getFilesFromRegex[args`file;args`dir];
    ignoreNonQScripts getFullPath args`file
  ];
  args[`exclude]:$[
    args`regex;getFilesFromRegex[args`exclude;args`dir];
    ignoreNonQScripts getFullPath args`exclude
  ];
  if[10h~type args`dir;  // Checking directory exists if dir argument was passed, if not exits with an error
    isInvalidDir:(()~args`dir)or @[{11h<>type key hsym`$x};args`dir;1b];
    if[isInvalidDir;-2"ERROR: Directory '",args[`dir],"' could not be found";exit 1];
  ];

  if[not[args`regex]and not ()~args`dir;args[`file]:distinct args[`file],getDirFileList args`dir];
  if[0<count args`file;args[`file]:filterExcluded[args`file;args`exclude]];
  
  lines:$[
    0<>count args`file;[
      -1"Scanning ",string[count args`file]," .q script(s) . . .";
      raze scanFile[;checksDict] each args[`file]
    ];
    [-1"No files to scan";()]
  ];

  -1"Scanned ",string[count args`file]," .q script(s)";
  -1"Total lines with possible incompatibilities: ",string count lines;

  $[
    (not ()~args[`csv])and 0<>count lines;writeToCsv[args`csv;checksDict;lines];
    0~count lines;-1"WARN: Skipped writing to csv, no lines to output";
    ()
  ];

  exit 0;
 };

getFilesFromRegex:{[regexList;dir]
  if[0~count regexList;:()];

  if[dir~();dir:first system"pwd"];
  res:raze{system"find ",x," -regextype posix-extended -type f -regex '",y,"'"}[dir]each regexList;

  :getFullPath ignoreNonQScripts res;
 };

ignoreNonQScripts:{[files]
  res:files where files like "*[.]q";
  if[count[res]<>count files;
    -1"WARN: Ignored ",string[count[files]-count res]," files that are not .q scripts"];

  :res;
 };

scanFile:{[file;checksDict]
  showProgressDots"Scanning '",file,"' ";
  res:system"printf '%s\\n' \"$(grep -nHE '",combineRegexList[value checksDict],"' '",file,"')\"";
  clearProgressDots[];
  
  if[""~raze/[res];res:()];

  :res;
 };

getDirFileList:{[dir]
  :getFullPath system"echo \"$(find '",dir,"' -name '*\\.q')\"";
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

  if[0h~type args`csv;args[`csv]:first args`csv];
  if[10h<>type args`csv;
    -1"WARN: No csv file name passed, automatically choosing a file name . . .";
    args[`csv]:generateCsvFileName[];
  ];

  if[(()~args`file) and ()~args`dir;
    -2"ERROR: Insufficient arguments passed";
    -1"";
    showHelp[];
  ];

  :args;
 };

generateCsvFileName:{[]
  tgtDir:{x,"/"}first system"pwd";
  fNamePrefix:"compatibility_scan_";

  fName:tgtDir,fNamePrefix,ssr[string .z.p;":";"."],".csv";
  -1"Output csv file will be: '",fName,"'";

  :fName;
 };

loadChecksDict:{[]
  checksDict:enlist[`z_assignment]!enlist readAssignmentChecks ASSIGNMENT_CHECKS_TSV;
  checksDict,:enlist[`system_command]!enlist readCommandsChecks COMMANDS_CHECKS_TSV;

  if[DEBUG_SHOW_REGEX_PASSED;
    -1"DEBUG: Regex pattern being passed:";
    -1 combineRegexList value checksDict;
  ];
  
  :checksDict;
 };

readCommandsChecks:{[file]
  tbl:("**";enlist"\t") 0: hsym`$file;

  :combineRegexList tbl`regex;
 };

readAssignmentChecks:{[file]
  tbl:("**";enlist"\t") 0: hsym`$file;

  :combineRegexList raze{
    :enlist[y] cross x cross enlist z;
  }[ZS_TO_CHECK]'[tbl`prefix;tbl`suffix];
 };

combineRegexList:{[checksList]
  :-1 _ raze{"(",x,")|"}each checksList;
 };

filterExcluded:{[files;excludedFiles]
  :files where not files in excludedFiles;
 };

writeToCsv:{[file;checksDict;lines]
  file:getFullPath file;
  if[not file like "*[.]csv";
    -1"WARN: Adding '.csv' suffix to file '",file,"'";
    file,:".csv";
  ];

  tbl:categoriseLines[checksDict;lines];

  -1"Saving results to file '",file,"' . . .";
  @[{(hsym`$x) 0: csv 0: y;-1"Saved"}[file];tbl;
    {[x;y] -2"ERROR: Could not save to '",x,"' due to:\n",y}[file]];
 };

categoriseLines:{[checksDict;lines]
  -1"Splitting output lines into categories...";

  tbl:raze categoriseLine[checksDict]each lines;

  -1"Splitted output lines";

  :tbl;
 };

categoriseLine:{[checkDict;line]
  showProgressDots"Splitting output lines ";
  
  res:raze{[check;checkRegex;line]
    lineDict:{`file`lineNum`code!(x 0;"J"$x 1;":" sv 2 _ x)}":" vs line;

    found:0<"J"$first system"printf '%s' $(echo '",ssr[lineDict[`code];"'";"'\\''"],"' | grep -cE '",checkRegex,"' )";
    if[not found;:()];

    :([]
      category:enlist check;
      file:enlist lineDict`file;
      line_num:enlist lineDict`lineNum;
      code:enlist lineDict`code
    );
  }[;;line]'[key checkDict;value checkDict];

  clearProgressDots[];

  :res;
 };

showProgressDots:{[prefixStr]  // Used to give the user a visual indication that the program is still progressing without clogging up the logs
  .progressTracker.dotNum:@[{mod[1+value x;4]};`.progressTracker.dotNum;0];
  1 prefixStr,.progressTracker.dotNum#".";
 }

clearProgressDots:{[]  // Clears the line for the next step to print over it (ANSI escape code to erase current line + carriage return)
  1"\033[2K\r";
 };

showHelp:{[]
  -1"+--------------------------------+";
  -1"| FinSpace Compatibility Scanner |";
  -1"+--------------------------------+";
  -1"[Arguments]";
  -1"";
  -1"-dir:      [Required if -file not passed]";
  -1"           Directory to scan";
  -1"           e.g.: -dir '/home/username/TorQ'";
  -1"";
  -1"-file:     [Required if -dir not passed]";
  -1"           In normal mode: Scans file(s);";
  -1"           In regex mode:  Scans file(s) matching regex in dir";
  -1"                           (or from `pwd` if no dir is passed)";
  -1"           e.g. (Normal mode): -file '/path/to/file0.q' 'path/to/file1.q'";
  -1"           e.g. (Regex mode):  -dir 'TorQ' -file '.*processes.*' --regex";
  -1"";
  -1"-csv:      [Optional]";
  -1"           CSV file to output the results to, otherwise a new file";
  -1"           'compatibility_scan_X.csv' is made in the current working directory";
  -1"           (Adds '.csv' to the end of the filename if not provided)";
  -1"           e.g.: -csv '/path/to/file.csv'";
  -1"";
  -1"-exclude:  [Optional]";
  -1"           In normal mode: Excludes file(s) from scan;";
  -1"           In regex mode:  Excludes file(s) from scan matching regex in dir";
  -1"                           (or from `pwd` if no dir is passed)";
  -1"           e.g. (Normal mode): -exclude '/ignore/this/file.q' '/and/this/file.q'";
  -1"           e.g. (Regex mode):  -dir 'TorQ' -exclude '.*[rh]db\\.q' --regex";
  -1"";
  -1"--regex:   [Optional]";
  -1"           Switch file and exclude arguments from normal mode to regex mode";
  -1"           (POSIX-Extended)";
  -1"           e.g.: -dir 'TorQ' -file '.*processes.*' -exclude '.*db\\.q' --regex";
  -1"";

  exit 0;
 };

run[];
