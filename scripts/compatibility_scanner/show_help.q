showHelp:{[]
  -1"+--------------------------------+";
  -1"| FinSpace Compatibility Scanner |";
  -1"+--------------------------------+";
  -1"[Arguments]";
  -1"";
  -1"-dir:      Directory to scan";
  -1"-file:     In normal mode: Scans file(s);";
  -1"           In regex mode:  Scans file(s) matching regex in dir";
  -1"                           (or from `pwd` if no dir is passed)";
  -1"-exclude:  In normal mode: Excludes file(s) from scan;";
  -1"           In regex mode:  Excludes file(s) from scan matching regex in dir";
  -1"                           (or from `pwd` if no dir is passed)";
  -1"--regex:   Switch file and exclude arguments to regex mode (posix-extended)";
  -1"";

  exit 0;
 };
