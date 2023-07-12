import flywheel

with open('/Users/hillmann/Projects/Evolution/Scripts/process/flywheel/flywheel_api_key.txt', 'r') as f:
    API_KEY = f.read().strip()

fw = flywheel.Client(API_KEY)
project = fw.projects.find_first('label=Evolution_833922')

for sub in project.subjects():
    for ses in sub.sessions(): 
        bids_names = []
        for acq in ses.acquisitions():
            acq = acq.reload()
            for f in acq['files']:
                if f.type == 'nifti':
                    try:
                        file_name = f.info['BIDS']['Filename']
                        if file_name in bids_names and f.info['BIDS']['Folder'] in ['anat','dwi','fmap','func']:
                            print(f"Subject: {sub.label},Session: {ses.label},Acquisition: {acq.label}")
                        bids_names.append(file_name)  
                    except:
                        continue
                              
