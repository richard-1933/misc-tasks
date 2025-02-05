#!/bin/bash

# 1. Check the operating system
os=$(uname)

# 2. Create a temporary file for error messages
if [ "$os" = "Linux" ]; then
    errtemp=$(mktemp)
elif [ "$os" = "HP-UX" ]; then
    errtemp="/tmp/errtemp$$"
    touch "$errtemp"
else
    echo "Unsupported operating system: $os"
    exit 1
fi

# 3. Redirect standard error to the temporary file
exec 2> "$errtemp"

# 4. Call the handler when receive exit signal
if [ "$os" = "Linux" ]; then
    trap handle_on_exit EXIT
elif [ "$os" = "HP-UX" ]; then
    trap handle_on_exit 0
fi

#############################################
#   handle error message on exit
#############################################
handle_on_exit(){
    #process if $errtemp is exist and not empty
    if [ -s "$errtemp" ]; then
        #process error message (call api or sp)

        echo "Global Error Content:===================="
        cat "$errtemp"
        # process error message here (呼叫API或SP處理錯誤訊息)

        echo "========================================="
        echo "Global Error: $errtemp has been processed!!"
    fi
    #clean up
    rm -f "$errtemp"
}

#############################################
#   append custom error message to global error file
#############################################
append_error(){
    #read from file
    if [ -s "$1" ]; then
        cat "$1" >> "$errtemp"
    else #read from stdin
        while IFS= read -r line; do
            echo "$line" >> "$errtemp"
        done
    fi
}