from zipfile import ZipFile
from os.path import basename
import flywheel
import os

fw = flywheel.Client()
output_dir = '/home/hillmann/Projects/Evolution/Data/ASL_Dicom_Files'

project = fw.projects.find_first('label=Evolution_833922')

for sess in project.sessions():
    if sess['subject']['label'] == '118546':
        for acq in sess.acquisitions():
            if 'pcasl' in acq['label']:
                for file in acq['files']:
                    if 'dicom.zip' in file['name'] and 'Removed2ndScan' in file['name']:
                        acq.replace_file_info(file['name'], {'zip_member_count': 15})
