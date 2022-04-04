from zipfile import ZipFile
from os.path import basename
import flywheel
import os

fw = flywheel.Client()
output_dir = '/Users/hillmann/Projects/Evolution/Data/ASL_Dicom_Files'

project = fw.projects.find_first('label=Evolution_833922')

for sess in project.sessions():
    if sess['subject']['label'] ==  '118546':
        for acq in sess.acquisitions():
            if 'pcasl' in acq['label']:
                for files in acq['files']:
                    if files['type'] == 'dicom':
                        zip_file_name = files.name
                        zip_info = acq.get_file_zip_info(zip_file_name)
                        filenames = []
                        arcnames = []
                        for i in range(len(zip_info.members)):
                            if i == 1:
                                continue
                            else:
                                entry_name = zip_info.members[i].path
                                work_dir = os.path.join(output_dir,'Subject',sess['subject']['label'],'Session',sess['label']) 
                                subj_dir = os.path.join(output_dir,"Subject")
                                if not os.path.exists(subj_dir):
                                    os.mkdir(subj_dir)
                                subj_id_dir = os.path.join(subj_dir,sess['subject']['label'])
                                if not os.path.exists(subj_id_dir):
                                    os.mkdir(subj_id_dir)
                                sess_dir = os.path.join(subj_id_dir,'Session')
                                if not os.path.exists(sess_dir):
                                    os.mkdir(sess_dir)
                                sess_id_dir = os.path.join(sess_dir,sess['label'])
                                if not os.path.exists(sess_id_dir):
                                    os.mkdir(sess_id_dir)
                                out_path = os.path.join(work_dir,entry_name.split('/')[1])
                                acq.download_file_zip_member(zip_file_name, entry_name, out_path)
                                filenames.append(out_path)
                                arcnames.append(entry_name.split('/')[1])
                        ZipfileName = "Removed2ndScan_"  + entry_name.split('/')[0] + ".zip"
                        with ZipFile(os.path.join(work_dir,ZipfileName), 'w') as zipObj:
                            for i in range(len(filenames)):
                                zipObj.write(filenames[i],arcnames[i]) 
                        #acq.upload_file(os.path.join(work_dir,ZipfileName))
                            
