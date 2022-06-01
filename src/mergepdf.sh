#!/bin/bash

#----------------------------------------------------------------------------------------------------
#   Author :        Shlomo Stept
#   Program :       mergepdf.sh  : script to merge pdfs
#   Last Modified : 5/30/22
#   Description :   this script works in conjunction with a python script,
#                   to merge all pdfs located in a folder or some specified my the user
#   Process     :    (i)    parse and validate arguments,
#                    (ii)   possibly find the full file-path if -f is specified
#                    (iii)  call python script to merge files
#   Notes :
#            Usage : ./mergepdf.sh  [ -options ]  < Files / Directory >  < Merge-File Name >"
#            flag options:
#                -a : all the files in the folder
#                -s : some of the files , and then they must be listed
#                -f : full pathname not specified -- program must find the full filepath for all files
#
#               Warning: -f flag must be specified before -s/a flag.
#                         - Example: ./mergepdf.sh -f -s <file-1> <file-2> <output_name>"
#               Default : the script will find all the files in the specified folder and merge them
#----------------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------------

 
#----------------------------------------------------------------------------------------------------
#   Step 0 :  Declare all varaibles that will be used, and helper functions
#----------------------------------------------------------------------------------------------------
declare -a file_array
dir_path=""
file_name=""
full_file_path=""
all_files=()
get_full_pathnames=0
flag_entered=0      # -a has value of 1, -s has value of 2
option_chosen=""
LINE="----------------------------------------------------------------------------------------------------"
HALF_LINE="----------------------------------------------"
#----------------------------------------------------------------------------------------------------


#----------------------------------------------------------------------------------------------------
#   Step 0.5 :  Helper Functions
#----------------------------------------------------------------------------------------------------
function usage {
    echo $LINE ;
    echo " Usage : $0  [ -options ]  < Files / Directory >  < Merge-File Name >" ;
    echo " Options are as follows: " ;
    echo "  -a   :   Merge all files in the specified Directory " ;
    echo "  -s   :   Merge specified files" ;
    echo "  -f   :   Filepath Not specified - program should determine the full filepath " ;
    echo "  Note :   -f flag must be specified before -s/a flag.   Example: ./mergepdf.sh -f -s <file-1> <file-2> <output_name>"
    echo $LINE ;
 }
#----------------------------------------
function error(){
    [[ "$1" ]] && {
        echo $LINE ;
        echo "$1" ;
    }
    usage ;
    exit 1 ;
}
#----------------------------------------
function find_start () {
    all_args=( "$@" ) ;
    for i in ${!all_args[@]} ; do
        if [[ ${all_args[$i]} == *"-s"* ]] ; then
            start=$(( $i + 1 )) ;
            echo $start
            return 0;
        fi
    done
}

#----------------------------------------
#----------------------------------------------------------------------------------------------------



#----------------------------------------------------------------------------------------------------
#   Step 1 :  make sure there are at least 3 entries --> not including args
#----------------------------------------------------------------------------------------------------
if [[ $# -lt 3 ]] ; then  usage ; exit 0 ;  fi


#----------------------------------------------------------------------------------------------------
#   Step 2 : process and parse input : first use getopts to get the filename and save in array
#----------------------------------------------------------------------------------------------------

while getopts ":a:s:f" option; do
    case "${option}" in
        a)
            if [[ ! -d $OPTARG ]] ; then
                error "Error: [ option -a ] a directory must be specified.   -->  \"$OPTARG\" is not a directory."
            fi
            old_path="$PWD"
            path="$OPTARG"
            cd "$path"
            for file_name in "$PWD"/* ; do
                file_array[${#file_array[@]}]="$file_name" ;
            done
            cd "$old_path"

            arg_array=( "$@" )
            size=${#arg_array[@]}
            file_array[${#file_array[@]}]="${arg_array[$(( $size - 1 )) ]}"
            flag_entered=1 ;                                   # One of the required options were selected
            ;;
        
        s)
            # saves all the filenames into an array (note last filename is the name for merged file)
            all_args=( "$@" ) ;
            start=$( find_start "$@" ) ;
            size=$(( ${#all_args[@]} - $start))
            file_array=("${all_args[@]:$start:$size}") ;
            flag_entered=2 ;                                    # One of the required options were selected
            ;;
        
        f)  #    TO DO  -- Clean the get_fullpath function
            get_full_pathnames=1 ;
            ;;

        :)                                                          # This runs : If the no argument was recieved with for a flag - that requires an argument
            error "Error: -${OPTARG} requires an argument." ;       # Exit with an error
            ;;

        *)                                                          # This runs : If the flag is not one the ones specified above this runs
            error "Error "-${OPTARG}    ;                           # Exit with that "illegal argument"
            ;;
    esac
done


#----------------------------------------------------------------------------------------------------
#   Step 2.1 : make sure either -s or -a was entered --> print out usage message if not
#----------------------------------------------------------------------------------------------------
if [[ $flag_entered -eq 0 ]] ; then
    error ":: Error: one flag must be specified, [ options : -a , -s ] ::" ;
fi


#----------------------------------------------------------------------------------------------------
#   Step 2.2 : if -f flag was specified get the full pathname for each file
#----------------------------------------------------------------------------------------------------
if [[ $get_full_pathnames -eq 1  &&  !$flag_entered -eq 1 ]] ; then
    echo $LINE
    echo ":: Getting Full Pathnames :: "
    for ind in "${!file_array[@]}" ; do
        IFS=$'\n'
        paths=($( find ~ -name  ${file_array[$ind]} -print 2>/dev/null | grep -v "Permission denied"  )) ;
        unset IFS ;
        if [[ ${#paths[@]} -eq 0 ]] ; then
            # TO DO --> CHECK IF THEY HAVE A .pdf ending and if not add and then search using find again
            echo "No file found for : ${file_array[$ind]}"
        elif [[ ${#paths[@]} -gt 1 ]] ; then
            echo $LINE
            echo "     :: Warning! :: Multiple files found for filename : \"${file_array[$ind]}\"      "
            echo "     ->    Select the number corresponding to the correct file-path     "
            echo $LINE
            for i in ${!paths[@]} ; do
                echo "  $i) ${paths[$i]}"
            done
            read option_chosen ;
            echo " - merging : ${paths[$option_chosen]} "
            file_array[$ind]="${paths[$option_chosen]}" ;
        else
            file_array[$ind]="${paths}" ;
        fi
    done
fi


#----------------------------------------------------------------------------------------------------
#   Step 2.3 : remove any bad entries (in this case were refering to directories), and make sure there are still 2 files to merge
#----------------------------------------------------------------------------------------------------
# 1 - check that the -f was put before the -s
for path in "${file_array[@]}" ; do
    if [[ $path == "-f" ]] ; then
        error "Error: -f flag must be specified before -s/a flag.   Example: ./mergepdf.sh -f -s <file-1> <file-2> <output_name>"
    fi
done

# 2 - remove any bad entries
echo $LINE
echo  "  :: Starting Merge :: "
echo $HALF_LINE
declare -a final_file_array
for path in "${file_array[@]}" ; do
    size=$(( ${#file_array[@]}  - 1 )) # need to declare this -bad substitution
    if [[ -d "$path" ]] ; then
        echo " ~~~~ Skipping Directory    :: $path " ;
    elif [[ ! "$path" =~ ".pdf"  &&  "$path" != "${file_array[${size}]}" ]] ; then
        echo " ~~~~ Skipping Non-PDF File :: $path " ;
    else
        echo " - adding file : $path " ;
        final_file_array[${#final_file_array[@]}]="$path" ;
    fi
done

# 3 - check that user specified at least two files to merge
if [[ ${#final_file_array[@]} -lt 3 ]] ; then
    error " Error : At least three files are required. ( 2-merge, 1-final name )" ;
else 
    echo $HALF_LINE
fi




#----------------------------------------------------------------------------------------------------
#   Step 3 : call the python merging script and supply it with all the required arguments
#----------------------------------------------------------------------------------------------------
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";
python3 "$SCRIPT_DIR/py/merge_pdfs.py" "${final_file_array[@]}" ;  # TODO :: MUST manually specify file location

######### TO DO _____CREATE BASH SCRIPT TO INSTALL/MAKE THIS CALLABLE FROM ANYWHERE AS A BASH COMMAND ON ** ANY COMPUTER***

