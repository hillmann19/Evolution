import flywheel

with open('/Users/hillmann/Projects/Evolution/Scripts/process/flywheel/flywheel_api_key.txt', 'r') as f:
    API_KEY = f.read().strip()

fw = flywheel.Client(API_KEY)
project = fw.projects.find_first('label=Evolution_833922')

for sub in project.subjects():
    if 'pilot' in sub.label:
        continue
    # Loop through sessions in subject
    for ses in sub.sessions():
        ses = ses.reload()
        # Loop through acquisitions in session
        for acq in ses.acquisitions():
            acq = acq.reload()
            # Loop through files in acquisition
            for f in acq.files:
                if f.type == 'nifti':
                    try:
                        if f.info['BIDS']['Folder'] == 'perf' and 'Removed' not in f.name:
                            f.info['BIDS']['Folder'] = ''
                            f.update_info({'BIDS':  f.info['BIDS']})
                        elif '_incomplete' in acq.label:
                            f.info['BIDS']['Folder'] = ''
                            f.update_info({'BIDS': f.info['BIDS']})
                        
                        elif 'anat_T2w' in acq.label and (f.info['ImageType'][4] == 'MOSAIC' or f.info['ImageType'][4] == 'NORM'):
                            f.info['BIDS']['Folder'] = ''
                            f.update_info({'BIDS': f.info['BIDS']})
                        
                        else:
                            continue
                    except:
                        continue                   





