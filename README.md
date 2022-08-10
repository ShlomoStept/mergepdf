# mergepdf
Small script to merge multiple pdfs into one

The MacOS's preview app has this functionality, but its slow, manual, and annoying, when its not freezing on you ; and most websites only allow you to do one merge per day, so i got annoyed and wrote this. 

#### Notes :
  1. if you want to make work like a regular terminal command follow the steps outlined by johnathan (3rd answer) on stackoverflow 
     > https://stackoverflow.com/questions/3560326/how-to-make-a-shell-script-global.
  2. This script has been tested on the Mac and Linux systems.

## Usage
```sh
 ./mergepdf.sh  [ -options ]  <files-to-be-merged>/<path-to-folder>  < name-for-output-file >
   flag options: 
        -a : merge all the files in a folder, and then specify the folder. For current directory use .        (TODO - the default is the current folder)
        -s : some of the files , and then list them                                                           (TODO - the default is -s, with the first 2+ file names assumed to be the onesto be merged and last being the name-of-output-file)
        -f : full pathname not specified -- program will find the full filepath for all files ( if they exist )
```

## Requirements

- You need Python 3.6+ and pip to install and use this script
- You need PyPDF2 as well.
- bash

#### Installing dependancies 
```sh
pip install -r requirements.txt
```

