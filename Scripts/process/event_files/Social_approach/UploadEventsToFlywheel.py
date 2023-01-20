import logging
import re
import pdb
import operator
import pprint
import mimetypes
import flywheel
import json
import pandas as pd
from os import path
from pathvalidate import is_valid_filename
from pathlib import Path
from fw_heudiconv.cli.export import get_nested

with open('/Users/hillmann/Projects/Evolution/Scripts/process/flywheel/flywheel_api_key.txt', 'r') as f:
	API_KEY = f.read().strip()
fw = flywheel.Client(API_KEY)
project = fw.projects.find_first('label=Evolution_833922')

def none_replace(str_input):
    return str_input

def force_template_format(str_input):

    # if we get a reproin heuristic, the str format is:
    #
    # {bids_subject_session_dir}/anat/{bids_subject_session_prefix}_scout
    #
    # here we replace the {} with the sub-sess format fw-heudiconv uses

    str_input = re.sub("{bids_subject_session_dir}", "sub-{subject}/ses-{session}", str_input)
    str_input = re.sub("{bids_subject_session_prefix}", "sub-{subject}_ses-{session}", str_input)

    # next, we remove extra sub-sub or ses-ses
    str_input = re.sub("(?<!ses-){session}", "ses-{session}", str_input)
    str_input = re.sub("(?<!sub-){subject}", "sub-{subject}", str_input)

    return(str_input)

def force_label_format(str_input):

    str_input = re.sub("ses-", "", str_input)
    str_input = re.sub("sub-", "", str_input)

    return(str_input)

def verify_attachment(name, data, dtype='text/tab-separated-values'):

    types = mimetypes.types_map

    # check for extension
    # if found, check its dtype matches
    ext = path.splitext(name)[1]
    valid_fname = is_valid_filename(name)

    if ext:

        output_dtype = types.get(ext, None)
        if dtype == output_dtype:
            valid_dtype = True
        else:
            valid_dtype = False
    else:
        # no extension, just check dtype
        valid_dtype = dtype in list(mimetypes.types_map.values())

    valid_data = isinstance(data, str)

    return valid_fname, valid_data, valid_dtype

def upload_attachment(target_object, level, attachment_dict,
    subject_rename=None, session_rename=None,
    folders=['anat', 'dwi', 'func', 'fmap', 'perf'],
    dry_run=True
        ):
    '''processes and uploads the attachment
    '''

    bids = {
        "Filename": None,
        "Folder": None,
        "Path": None
        }

    if level == 'project':
        bids.update({
            "Filename": attachment_dict['name'],
            "Path": '.'
            })
    else:

        # manipulate sub and ses labels
        subj_replace = none_replace if subject_rename is None else subject_rename
        subj_label = subj_replace(force_label_format(target_object.subject.label))

        ses_replace = none_replace if session_rename is None else session_rename
        sess_label = ses_replace(force_label_format(target_object.label))

        attachment_dict['name'] = force_template_format(attachment_dict['name'])
        attachment_dict['name'] = attachment_dict['name'].format(subject=subj_label, session=sess_label)

        # get the dir/folder/path
        dirs = Path(attachment_dict['name']).parts
        folder = [x for x in dirs if x in folders]
        if not folder:
            folder = None
        else:
            folder = folder[0]

        path = str(Path(attachment_dict['name']).parent)

        # get filename
        attachment_dict['name'] = str(Path(attachment_dict['name']).name)

        # get BIDS ready
        bids.update({
            "Filename": str(Path(attachment_dict['name']).name),
            "Folder": folder,
            "Path": path
            })

    verify_name, verify_data, verify_type = verify_attachment(
        attachment_dict['name'], attachment_dict['data'], attachment_dict['type']
        )

    if not all([verify_name, verify_data, verify_type]):

        print("Attachments may not be valid for upload!")  

    if not dry_run:
        file_spec = flywheel.FileSpec(
            attachment_dict['name'], attachment_dict['data'], attachment_dict['type']
            )
        target_object.upload_file(file_spec)
        target_object = target_object.reload()
        target_object.update_file_info(attachment_dict['name'], {'BIDS': bids})


sessions = fw.get_project_sessions(project.id)
for ses in sessions:
    subj_label = ses.subject.label
    ses_label = ses.label
    try:
        sa_df = pd.read_csv(f"~/Projects/Evolution/Data/AllEventsFilesSA/{subj_label}_{ses_label}_SAevents.csv")
    except:
        print(f"Subject: {subj_label}, Session: {ses_label} not found")
        continue
    sa_events = {
        'name': 'sub-{subject}/{session}/func/sub-{subject}_{session}_task-socialapproach_dir-AP_events.tsv',
        'data': sa_df.to_csv(index=False, sep='\t'),
        'type': 'text/tab-separated-values'
        }

    upload_attachment(ses, level='session', attachment_dict=sa_events,
                    subject_rename=None, session_rename=None,
                    folders=['anat', 'dwi', 'func', 'fmap', 'perf'],
                    dry_run= True
                        )
