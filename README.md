# mergepdf
Small script to merge multiple pdfs into one

Mac's preview app has this functionality, but it keeps freezing on me; and most websites only allow you to do one merge per day, so i got annoyed and wrote this. 
Its not perfect but it works well. 

#### Note : if you want to make work like a regular terminal command follow the steps outlined by johnathan (3rd answer) on stackoverflow https://stackoverflow.com/questions/3560326/how-to-make-a-shell-script-global.
- my script only works on my atypical mac-setup 

## Usage
```sh
 ./mergepdf.sh  [ - options ]  < Files / Directory >  < Merge-File Name >
   flag options: 
        -a : all the files in the folder
        -s : some of the files , and then they must be listed
        -f : full pathname not specified -- program will find the full filepath for all files (if they exist )
```

## Requirements

- You need Python 3.6+ and pip to install and use this script
- You need PyPDF2 as well.
- bash

#### Installing dependancies 
```sh
pip install -r requirements.txt
```

