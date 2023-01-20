log_dir="/Users/hillmann/Projects/Evolution/Data/Social_approach/Log_Files_Evolution"
subjects=`ls ${log_dir}`
output_dir='/Users/hillmann/Projects/Evolution/Data/Social_approach/AllLogFilesSA'
mkdir -p ${output_dir}

for subj in ${subjects};do 
	if [ ${subj} == 'Piloting_Data' ]
	then 
		continue
	else 
          log_file_array=(${log_dir}/${subj}/*Social_approach_no_eyetracker*.log)
	  if [[ ${#log_file_array[@]} -gt 1 ]];
	  then 
		log_file=`ls ${log_dir}/${subj} | grep "Social_approach_no_eyetracker.log" | tail -1`
		cp ${log_dir}/${subj}/${log_file} ${output_dir}
	  else
	  	cp ${log_file_array} ${output_dir}
	  fi
    fi
done
