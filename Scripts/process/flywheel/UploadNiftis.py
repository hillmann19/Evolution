import flywheel
import os
import re 
import json

fw = flywheel.Client()
output_dir = '/home/hillmann/Projects/Evolution/Data/ASL_Dicom_Files'

project = fw.projects.find_first('label=Evolution_833922')
data_dir = '/project/bbl_gur_evolpsy/data/Flywheel/Evolution_833922/SUBJECTS'
for sess in project.sessions():
    acqs = []
    for acq in sess.acquisitions():
        num_suffix = sum([1 if acq.label == a else 0 for a in acqs]) - 1
        if num_suffix >= 0:
            acq_new_label = acq.label + '_' + str(num_suffix)
        else:
            acq_new_label = acq.label
        acqs.append(acq.label)
        files_dir = os.path.join(data_dir,sess.subject.label,'SESSIONS',sess.label,'ACQUISITIONS',acq_new_label,'FILES')
        files_in_pmacs = os.listdir(files_dir)
        for f in files_in_pmacs:
            if f.endswith('.json') or f.endswith('nii.gz'):
                acq.upload_file(os.path.join(files_dir,f))
                if f.endswith('nii.gz'):
                    dicom_of_f = re.sub('.nii.gz$','.dicom.zip',f)
                    json_of_f = re.sub('.nii.gz$','.json',f)
                    for s in acq['files']:
                        if s.name == dicom_of_f:
                            with open(os.path.join(files_dir,json_of_f),'r') as data:
                                sidecar = data.read()
                            sidecar_no_n = sidecar.replace('\n','')
                            sidecar_clean = sidecar_no_n.replace('\t','')
                            metadata = json.loads(sidecar_clean)
                            s_class = s.classification
                            s_mod = s.modality
                            acq.replace_file_info(f,metadata)
                            acq.replace_file_classification(f,classification=s_class,modality=s_mod)
    
                    
                    

            
