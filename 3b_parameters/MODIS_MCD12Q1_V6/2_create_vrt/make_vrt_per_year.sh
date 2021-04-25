#!/bin/bash

# Make a virtual dataset (VRT) for each year of MODIS data, for easier data handling.
# First creates .txt files that contain the names of .h5 files per year, then creates separate VRTs for each year.

# load gdal
module load nixpkgs/16.09 gcc/5.4.0 gdal-hdf4/2.1.3
#module load gdal


#---------------------------------
# Specify settings
#---------------------------------

# --- Location of raw data
dest_line=$(grep -m 1 "parameter_land_raw_path" ../../../0_control_files/control_active.txt) # full settings line
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
 source_path="${root_path}/domain_${domain_name}/parameters/landclass/1_MODIS_raw_data"

fi


# --- Location where converted data needs to go
dest_line=$(grep -m 1 "parameter_land_vrt1_path" ../../../0_control_files/control_active.txt) # full settings line
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
 dest_path="${root_path}/domain_${domain_name}/parameters/landclass/2_vrt_native_crs"
fi

# Make destination directory 
mkdir -p "${dest_path}/filelists"


#---------------------------------
# Make the VRTs
#---------------------------------

# Loop over the years and create a .txt file that we can use as input for gdalbuildvrt
# Note that our variable of interest (MCD12Q1:LC_Type1) is stored in sub dataset 1 (-sd 1)
for YEAR in {2001..2018}
do
	# specify the output name for the file list
	OUTTXT="${dest_path}/filelists/MCD12Q1_filelist_"$YEAR".txt"

	# store the hdf files for that year in a temporary file
	ls $source_path/MCD12Q1.A$YEAR* >> $OUTTXT

	# Specify the output name for the VRT
	OUTVRT="${dest_path}/MCD12Q1_"$YEAR".vrt"

	# Make the vrt
	gdalbuildvrt $OUTVRT -input_file_list $OUTTXT -sd 1

done


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
this_file='make_vrt_per_year.sh'
echo "Log generated by ${this_file} on `date '+%F %H:%M:%S'`"  > $log_path/$log_file # 1st line, store in new file
echo 'Created Virtual Datasets from MODIS .hdf data for each year of record.' >> $log_path/$log_file # 2nd line, append to existing file

# Copy this file to log directory
cp $this_file $log_path