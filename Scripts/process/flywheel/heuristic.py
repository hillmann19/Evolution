'''
Heuristic to curate the Evolution_833922 project.
Katja Zoner
Updated: 05/10/2021
'''

import os

##################### Create keys for each acquisition type ####################

def create_key(template, outtype=('nii.gz',), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')
    return template, outtype, annotation_classes

# Structural scans
t1w = create_key(
    'sub-{subject}/{session}/anat/sub-{subject}_{session}_T1w')

# Field maps - fMRI
fmap_fmriAP = create_key(
    'sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-fmri_dir-AP_epi')
fmap_fmriPA = create_key(
    'sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-fmri_dir-PA_epi')

# fMRI scans
rest = create_key(
    'sub-{subject}/{session}/func/sub-{subject}_{session}_task-rest_dir-AP_bold')
er40 = create_key(
    'sub-{subject}/{session}/func/sub-{subject}_{session}_task-er40_dir-AP_bold')
socialapproach = create_key(
    'sub-{subject}/{session}/func/sub-{subject}_{session}_task-socialapproach_dir-AP_bold')

# ASL scans
perf = create_key(
    'sub-{subject}/{session}/perf/sub-{subject}_{session}_acq-se_asl')

# Diffusion weighted scans
dwi = create_key(
    'sub-{subject}/{session}/dwi/sub-{subject}_{session}_dwi')

# Field maps - dwi 
fmap_dwiAP= create_key(
    'sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-dwi_dir-AP_epi')
fmap_dwiPA = create_key(
    'sub-{subject}/{session}/fmap/sub-{subject}_{session}_acq-dwi_dir-PA_epi')

#t2starw = create_key(
#    'sub-{subject}/{session}/anat/sub-{subject}_{session}_T2starw')

# QSM
## NOTE: Not a part of the BIDS Standard yet! --> add to .bidsignore
qsm_ph = create_key(
    'sub-{subject}/{session}/swi/sub-{subject}_{session}_echo-{item}_part-phase_GRE')
qsm_mag = create_key(
    'sub-{subject}/{session}/swi/sub-{subject}_{session}_echo-{item}_part-mag_GRE')

# T2w
t2w = create_key(
    'sub-{subject}/{session}/anat/sub-{subject}_{session}_T2w')

# Old T2w_ABCD sequence (present for several early subjects)
t2w_ABCD = create_key(
    'sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-ABCD_T2w')

############################ Define heuristic rules ############################

def infotodict(seqinfo):
    """Heuristic evaluator for determining which runs belong where
    allowed template fields - follow python string module:
    item: index within category
    subject: participant id
    seqitem: run number during scanning
    subindex: sub index within group
    """
    
    import pandas as pd

    # Curation Round 1 cutoff date -- not yet curating sessions added after this date.
    DATE_CUTOFF = pd.Timestamp('2022-03-01')
    
    # Info dictionary to map series_id's to correct create_key key
    info = {
        t1w: [], 
        rest: [], er40: [], socialapproach: [],
        fmap_fmriAP: [], fmap_fmriPA: [],
        fmap_dwiAP: [], fmap_dwiPA: [],
        perf: [], dwi: [],
        #t2starw: [], 
        qsm_ph: [], qsm_mag: [],
        t2w: [], t2w_ABCD: []
        }

    # List of series_descriptions to not include
    ignore_list = [
        'anat-scout',
        'anat-vnavsetter_acq-BC-T1w_seq-ABCD',
        'anat_acq-vnavsetter_T2w',
        'Perfusion_Weighted'
    ]

    def get_latest_series(key, s):
        info[key].append(s.series_id)

    for s in seqinfo:

        # If pilot subject, skip and don't add to BIDS
        if "pilot" in s.patient_id.lower():
            print(f'Skipping pilot subject: {s.patient_id}')
            continue
        
        # NOTE: For Curation Round 1, only process sessions that occurred before DATE_CUTOFF (2021-04-23)
        timestamp = pd.Timestamp(s.date)
        if timestamp > DATE_CUTOFF:
            continue

        protocol = s.protocol_name.lower()
        series_description=s.series_description.lower()

        # T1w
        if "mprage" in protocol and "navsetter" not in s.series_description:
            get_latest_series(t1w, s)

        # fMRI 
        elif "task-rest" in protocol:
            get_latest_series(rest, s)
        elif "task-er40" in protocol:
            get_latest_series(er40, s)
        elif "task-socialapproach" in protocol:
            get_latest_series(socialapproach, s)
        
        # Fieldmap
        elif "fmap" in protocol:
            # fMRI fmaps
            if "acq-fmri" in protocol:
                if "dir-ap" in protocol:
                    get_latest_series(fmap_fmriAP, s)
                elif "dir-pa" in protocol:
                    get_latest_series(fmap_fmriPA, s)
            # dwi fmaps
            elif "acq-dwi" in protocol:
                if "dir-ap" in protocol:
                    get_latest_series(fmap_dwiAP, s)
                elif "dir-pa" in protocol:
                    get_latest_series(fmap_dwiPA, s)
        
        # perf
        elif "pcasl" in protocol and not s.is_derived and 'Removed2ndScan' in s.dcm_dir_name:
            get_latest_series(perf, s)

        # dwi
        elif "dwi-multishell" in protocol:
            get_latest_series(dwi, s)

        # qsm
        elif "qsm" in protocol:
            if "P" in s.image_type:
                get_latest_series(qsm_ph, s)
            elif "M" in s.image_type:
                get_latest_series(qsm_mag, s)

        # t2w
        elif "t2w" in protocol and "navsetter" not in s.series_description:
            if "abcd" in protocol:
                get_latest_series(t2w_ABCD, s)
            # Disinclude T2w_SPC scan for now
            elif "spc" not in protocol:
                get_latest_series(t2w, s)

        # Don't print "not recognized" message for scans we're intentionally not including.
        elif s.series_description not in ignore_list:
            print("Series not recognized!: ", s.protocol_name, s.dcm_dir_name)

    return info

################## Hardcode required params in MetadataExtras ##################
## TODO: no clu ;(

MetadataExtras = {    
    perf: {
        "ArterialSpinLabelingType": "PCASL",
        "BackgroundSuppression": True,
        "LabelingDuration": 0.7, # TODO: which is correct?? From Azeez: 0.7s, from Mark: 1.5s 
        "M0Type": "Included", 
        "PostLabelingDelay": 2,
        "RepetitionTimePreparation": 4.3, # not required?
        "TotalAcquiredPairs": 7    
    }
}

# Should any other scans be listed here, or just fmri/dwi's?
IntendedFor = {
    fmap_fmriAP: [
        '{session}/func/sub-{subject}_{session}_task-rest_dir-AP_bold.nii.gz',
        '{session}/func/sub-{subject}_{session}_task-er40_dir-AP_bold.nii.gz',
        '{session}/func/sub-{subject}_{session}_task-socialapproach_dir-AP_bold.nii.gz'
    ],
    fmap_fmriPA:  [
        '{session}/func/sub-{subject}_{session}_task-rest_dir-AP_bold.nii.gz',
        '{session}/func/sub-{subject}_{session}_task-er40_dir-AP_bold.nii.gz',
        '{session}/func/sub-{subject}_{session}_task-socialapproach_dir-AP_bold.nii.gz'
    ],
    fmap_dwiAP: [
        '{session}/dwi/sub-{subject}_{session}_dwi.nii.gz'
    ],
    fmap_dwiPA: [
        '{session}/dwi/sub-{subject}_{session}_dwi.nii.gz'
    ]
}

# TODO: Need to get events tsv files
# TODO: Need to finalize aslcontext number/order of volumes
def AttachToSession():
    NUM_VOLUMES=7
    data = ['control', 'label'] * NUM_VOLUMES
    data = '\n'.join(data)
    data = 'volume_type\n' + 'm0scan\n' + data 
    
    # define asl_context.tsv file
    asl_context = {
        'name': 'sub-{subject}/{session}/perf/sub-{subject}_{session}_aslcontext.tsv',
        'data': data,
        'type': 'text/tab-separated-values'
    }

    import pandas as pd 

    er40_df = pd.read_csv("info/task-er40_events.tsv", sep='\t') 

    # define er40 events.tsv file
    er40_events = {
        'name': 'sub-{subject}/{session}/func/sub-{subject}_{session}_task-er40_dir-AP_events.tsv',
        'data': er40_df.to_csv(index=False, sep='\t'),
        'type': 'text/tab-separated-values'
    }
    
    return [asl_context,  er40_events]


####################### Rename session and subject labels #######################

# Use flywheel to gather a dictionary of all session session_labels
# with their corresponding index by time, within the subject
def gather_session_indices():

    import flywheel
    fw = flywheel.Client()

    proj = fw.projects.find_first('label="{}"'.format("Evolution_833922"))
    subjects = proj.subjects()

    # Initialize session dict
    # Key: existing session label
    # Value: new session label in form <proj_name><session idx>
    session_labels = {}

    for s in range(len(subjects)):

        # Get a list of the subject's sessions
        sessions = subjects[s].sessions()

        if sessions:
            # Sort session list by timestamp
            sessions = sorted(sessions, key=lambda x: x.timestamp)
            # loop through the subject's sessions, assign each session an index
            for i, sess in enumerate(sessions):
                session_labels[sess.label] = "EVOL" + str(i + 1)

    return session_labels

session_labels = gather_session_indices()

# Replace session label with <proj_name><session_idx>
def ReplaceSession(ses_label):
    return str(session_labels[ses_label])
