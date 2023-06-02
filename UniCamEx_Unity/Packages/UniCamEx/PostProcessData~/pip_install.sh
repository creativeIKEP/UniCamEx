#!/usr/bin/bash

Post_Process_Data_Dir=$(cd $(dirname $0); pwd)
cd "$1/Library/PythonInstall/bin"
./pip3 install -r $Post_Process_Data_Dir/requirements.txt
