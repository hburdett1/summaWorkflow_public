#!/bin/bash

# Make a virtual dataset (VRT) for tile of MERIT data, for easier data handling.
# First creates a .txt file that contain the names of all .tif files, then creates the VRT.

# load gdal
module load nixpkgs/16.09  gcc/5.4.0 gdal/2.1.3


#---------------------------------
# Specify settings
#---------------------------------

# --- Location of raw data
dest_line=$(grep -m 1 "parameter_dem_unpack_path" ../../../0_control_files/control_active.txt) # full settings line
source_path=$(echo ${dest_line##*|})   # removing the leading text up to '|'
source_path=$(echo ${source_path%%#*}) # removing the trailing comments, if any are present

# Specify the default path if needed
if [ "$source_path" = "default" ]; then
  
 # Get the root path and append the appropriate install directories
 root_line=$(grep -m 1 "root_path" ../../../0_control_files/control_active.txt)
 root_path=$(echo ${root_line##*|}) 
 root_path=$(echo ${root_path%%#*})

 # domain name
 domain_line==$(grep -m 1 "domain_name" ../../../0_control_files/control_active.txt)
 domain_name=$(echo ${domain_line##*|}) 
 domain_name=$(echo ${domain_name%%#*})
 
 # source path
 source_path="${root_path}/domain_${domain_name}/parameters/dem/2_MERIT_hydro_unpacked_data"

fi

# --- Location where converted data needs to go
dest_line=$(grep -m 1 "parameter_dem_vrt1_path" ../../../0_control_files/control_active.txt) # full settings line
dest_path=$(echo ${dest_line##*|})   # removing the leading text up to '|'
dest_path=$(echo ${dest_path%%#*}) # removing the trailing comments, if any are present

# Specify the default path if needed
if [ "$dest_path" = "default" ]; then
  
 # Get the root path and append the appropriate install directories
 root_line=$(grep -m 1 "root_path" ../../../0_control_files/control_active.txt)
 root_path=$(echo ${root_line##*|}) 
 root_path=$(echo ${root_path%%#*})

 # domain name
 domain_line==$(grep -m 1 "domain_name" ../../../0_control_files/control_active.txt)
 domain_name=$(echo ${domain_line##*|}) 
 domain_name=$(echo ${domain_name%%#*})
 
 # destination path
 dest_path="${root_path}/domain_${domain_name}/parameters/dem/3_vrt"
fi

# Make destination directory 
mkdir -p "${dest_path}/filelists"


#---------------------------------
# Make the VRTs
#---------------------------------

# Specify filenames for the filelist and the vrt
OUTTXT="${dest_path}/filelists/MERIT_Hydro_dem_filelist.txt"
OUTVRT="${dest_path}/MERIT_Hydro_dem.vrt"

# Find the .tif files and store in a .txt file we can use for gdalbuildvrt
find $source_path -name "*.tif" >> $OUTTXT

# Make the vrt
gdalbuildvrt $OUTVRT -input_file_list $OUTTXT -sd 1


#---------------------------------
# Code provenance
#---------------------------------
# Generates a basic log file in the domain folder and copies the control file and itself there.
# Make a log directory if it doesn't exist
log_path="${dest_path}/_workflow_log"
mkdir -p $log_path

# Log filename
today=`date '+%F'`
log_file="${today}_compile_log.txt"

# Make the log
this_file='make_merit_dem_vrt.sh'
echo "Log generated by ${this_file} on `date '+%F %H:%M:%S'`"  > $log_path/$log_file # 1st line, store in new file
echo 'Created Virtual Dataset from MERIT .tif data.' >> $log_path/$log_file # 2nd line, append to existing file

# Copy this file to log directory
cp $this_file $log_path