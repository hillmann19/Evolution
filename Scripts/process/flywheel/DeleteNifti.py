import flywheel
import pytz 
from datetime import datetime

fw = flywheel.Client()
output_dir = '/home/hillmann/Projects/Evolution/Data/ASL_Dicom_Files'

project = fw.projects.find_first('label=Evolution_833922')

ses = project.sessions()[5]
acq = ses.acquisitions()[0]
f = acq['files'][0]
f.modified < pytz.utc.localize(datetime(2021,1,1))

for sess in project.sessions():
    for acq in sess.acquisitions():
        for file in acq['files']:
            if (file.type == 'bval' or file.type == 'bvec') and :
                fw.delete_acquisition_file(acq.id,file.name)



                        
