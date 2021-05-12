#/bin/bash

print_usage() {
    cat <<EOF
Usage: $(basename $0) [options...] [path...]
Options:
  -h, --help              display help
  -d, --maxdepth <N>      print the results only if it is N or fewer levels
                            below the command line argument
  -r, --reverse           print the results in reversed chronological order
  -q, --quiet             print only the sorted list, which is useful in
                            a pipline
EOF
    exit
}

[ $# -eq 0 ] && print_usage && exit

SEARCHPATH=()
REVERSE=""
QUIET="false"

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -h | --help)
        print_usage
        exit
        ;;
    -d | --maxdepth)
        # check if -d is followed by a number
        ! [[ $2 =~ '^[0-9]+' ]] && echo "usage: -d <num>" && exit
        MAXDEPTH="-maxdepth $2"
        shift # past argument
        shift # past value
        ;;
    -r | --reverse)
        # reverse the sorting order
        REVERSE="-r"
        shift
        ;;
    -q | --quiet)
       # print only the file list
       QUIET="true"
       shift
       ;;
    *) # otherwise, treat as search paths
        [ ! -d $1 ] && echo "Invalid search path: $1" && exit
        SEARCHPATH+=("$1") # save the search path
        shift              # past argument
        ;;
    esac
done

# echo "find $SEARCHPATH $MAXDEPTH -type f -printf '%TY-%Tm-%Td %.8TT %p %s\n' | numfmt --field=4 --to=iec --padding=8 | sort $REVERSE"
if [ ${QUIET} != "false" ]; then
    find $SEARCHPATH $MAXDEPTH -type f -printf '%TY-%Tm-%Td %.8TT %p %s\n' | \
        numfmt --field=4 --to=iec --padding=8 | \
        sort $REVERSE | \
        awk '{print $3}'
else
    echo "MAXDEPTH        = ${MAXDEPTH}"
    echo "SEARCH PATH     = ${SEARCHPATH}"
    echo "REVERSE         = ${REVERSE}"
    echo "QUIET           = ${QUIET}"
    find $SEARCHPATH $MAXDEPTH -type f -printf '%TY-%Tm-%Td %.8TT %p %s\n' | \
        numfmt --field=4 --to=iec --padding=8 | \
        sort $REVERSE
fi

set -- "${SEARCHPATH[@]}" # restore positional parameters
