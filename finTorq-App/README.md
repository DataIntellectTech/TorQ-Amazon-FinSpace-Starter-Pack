# FinTorQ Application
This is a sample TorQ application which is designed for running in finspace

## Notable Differences

### env.q
The entry point script is `env.q` which sets initial environment variables and loads the main `torq.q` script. 
This is used because finspace does not allow setting environment variables or running shell scripts at startup
- only `.q` scripts are allowed.

### Loading code/hdbs

Generally the main process code file (e.g. `code/processes/discovery.q`) is passed as a command line parameter with the `-load` flag.
We can't do this in finspace as filepaths are not allowed as command line parameters (yet...).

To work around this, we include a `.proc.params[``load]` variable into the settings file.

This also includes for hdb's.

## Set Up

TODO


