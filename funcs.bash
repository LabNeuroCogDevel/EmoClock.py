# if we exit on error, say why
trap '[ "$?" -ne 0 ] && echo "$0 ended with error!"' EXIT

## given a echo string, log file, and potentially an output file
# report what exists
# ** return error if log doesn't exist **
# e.g. 
#  testnoproc "$s:$r" "$procfile" "$finalfile" || continue
function testnoproc {
    wherestr=$1
    procfile=$2
    finalfile=$3
    if [ -r "$procfile" ]; then

       if [ -n "$finalfile" -a ! -r "$finalfile" ]; then
        echo "* do not have $finalfile "
       fi

       echo "$wherestr started 
          rm $procfile # remove procfile to retry";
       sed "s/^/\t/" $procfile 
       return 1
    else
       return 0
    fi

}

# log msg with date optionally to a file
# USAGE: 
#   log 'message'
#   log 'message' /path/to/file
function log {
 [ -z "$1" ] && exiterr "log needs msg"
 # write to file or not
 if [ -n "$2" ]; then
  cmd="tee -a $2"
 else
  cmd="cat"
 fi

 echo "[$(date +%F\ %H:%M)] $1" | $cmd
}

# exit with error message
function exiterr {
 echo "$@"
 exit 1
}
