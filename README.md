# Evolution
Project which is examining genetic and environmental factors which affect the development of psychosis in a longitudinal sample

# BIDS Curation steps
1.	The logs for the social approach task must be collected from Box to create the event file for each subject. Run the scripts getLogFiles.sh -> SocialApproach_event.R -> UploadEventsToFlywheel.py to complete this task. Note that for Subject: 82467 Session: 11508 the log files have flopped the subject ID and the session ID. You may need to change some of the input directories in the script so that they specify where the log files are on your computer. 
2.	Correct the field map names for the DWI scans by running the script rename_fw_file.ipynb 
3.	Remove the 2nd scan from the ASL dicom files by using the AcquisitionFilesCheck.py. This script will create a new dicom file under the ASL acquisition with the prefix Removed2ndScan. Run dcm2niix in Flywheel to get the nifti for the newly uploaded dicom
4.	Use the heuristic.py script with fw-heudiconv-curate to perform BIDS curation
5.	After running fw-heudiconv-curate there will be scans in BIDS with the same file name for the following reasons: 
a.	There are two T2w images – one original and one norm filtered – that are being named the same
b.	Some sessions have multiple ER-40 sessions which appear to be duplicates
c.	The BIDS curation script will process both ASL scans (although we only want the ones with the prefix Removed2ndScan)
6.	Additionally, there are some sessions which appear to be duplicates of one another which will give problems when trying to export the BIDS data from Flywheel 
7.	To solve the problems explained in steps 5 & 6, attach the suffix ‘_incomplete’ to any acquisition which you want to skip over during BIDS curation, and then run the script Remove_BIDS_duplicates.py which will move duplicated data to the nonBids folder
8.	Export BIDS curated data to PMACS
9.	If any subjects in the bids_directory have names like “{subject}_{session}” and only have context files, remove the folder. The extra context files were named incorrectly and attached to the session at a previous point, so they are now superfluous
10.	If processing the data through fMRIPrep, you can see an example script at /project/ExtraLong/scripts/datafreeze-2021/process/fMRIPrep/ on PMACS and information about how to run fMRIprep at https://fmriprep.org/en/22.1.1/index.html


