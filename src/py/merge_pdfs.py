"""----------------------------------------------------------------------------------------------------
   Author :        Shlomo Stept
   Program :       merge_pdfs.py  : script to merge pdfs 
   Last Modified : 5/30/22
   Description :   this script works in conjunction with a bash script, 
                   to merge all pdfs located in a folder or some specified my the user
   Process     :    (i)    get and parse merge-files and the final file name from bash-input 
                    (ii)   merge the files
----------------------------------------------------------------------------------------------------"""


#------------------------------------------------------------------------------------------------------
#   Step 0 : (i) Import all the necessary Libraries, and (ii) Declare the variables that will be used.
#------------------------------------------------------------------------------------------------------
import sys
from PyPDF2 import PdfMerger

# ------- eliminate warnings
import warnings
warnings.filterwarnings("ignore")

# ::: varaibles that will be used
merged_file_name =""
filepaths_to_merge = []


#------------------------------------------------------------------------------------------------------
#   Step 1 :  get each files path, and save in an array.
#------------------------------------------------------------------------------------------------------
filepaths_to_merge = sys.argv[1:-1]
merged_file_name=sys.argv[len(filepaths_to_merge)+1]
if not ".pdf" in merged_file_name:
    merged_file_name+=".pdf"
 
# ---------------- double check for valid input   
if len(filepaths_to_merge) < 2:
    print("Error: User must specify 2 files to be merged")
    exit()
if merged_file_name == ".pdf" :
    print("Error: User must specify merged filename")
    exit()
    
#------------------------------------------------------------------------------------------------------
#   Step 2 : (i) Merge the files and (ii) Save to desktop – with the specified filename.
#------------------------------------------------------------------------------------------------------

merge_object = PdfMerger()

for file in filepaths_to_merge:
     merge_object.append(file)
     
merge_object.write(str(merged_file_name))
merge_object.close()

print(" :: Merging Complete ::")
