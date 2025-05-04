import os
import io
import pandas as pd
import functions_framework
import logging
import google.cloud.logging_v2.client as cloud_logging
from cloudevents.http import CloudEvent
from utils.gcs_processor import GCSProcessor
from utils.load_bigquery import load_data_bigquery
import log_message as LogMessage

from datetime import datetime, date

PROJECT_ID = os.environ.get("PROJECT_ID")
SPLITTER   = os.environ.get("SPLITTER", None)
DATESET = os.environ.get("DATASET")
REGION = os.environ.get("REGION")
ARCHIEVE_BUCKET = os.environ.get("ARCHIEVE_BUCKET")
FILE_ENCODING = os.environ.get("file_encoding", "utf-8")
function_name = os.environ.get('K_SERVICE', 'Not set')

gcs_processor = GCSProcessor()
client =cloud_logging.Client.setup_logging()

@functions_framework.cloud_event
def data_loading(cloud_event: CloudEvent):

    try:  
        logging.info("Start the pipeline to process the file")
        print(cloud_event.data)
        LogMessage.create_message(PROJECT_ID, function_name, REGION, "", "Start the pipeline to process the file", "INFO", "", "")
        event = cloud_event.data
        incoming_bucket_name = event['bucket']
        incoming_blob_path = event['name']
        print(f"Loading data from bucket {incoming_bucket_name} and path {incoming_blob_path} ")

        filename = gcs_processor.file_name_substring("/", incoming_blob_path)
        print(f"The file name is: {filename} ")

        if filename.lower().endswith(".csv"):
            print(f"File from the bucket is CSV ")
            payload = gcs_processor.download_blob_content(incoming_bucket_name, incoming_blob_path)
            payload_io = io.StringIO(payload.decode(FILE_ENCODING))
            payload_io.seek(0)
            timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
            csv_input = pd.read_csv(payload_io, sep=SPLITTER, dtype=str)
            csv_input['FILE_NAME'] = filename
            csv_input['FETCH_DATE'] = timestamp

            logging.info("The csv file is parsed and will be loaded in the table")
            load_data_bigquery(PROJECT_ID, DATESET, csv_input)
            archive_blob_path = f"success/{(date.today()).strftime('%Y%m%d')}/{timestamp}_{filename}"
            print(archive_blob_path)
            gcs_processor.gcs_copy_blob(incoming_bucket_name, incoming_blob_path, ARCHIEVE_BUCKET, archive_blob_path)
        else:
            print(f"File from the bucket is not CSV ")
            timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
            archive_blob_path = f"fail/{(date.today()).strftime('%Y%m%d')}/{timestamp}_{filename}"
            gcs_processor.gcs_copy_blob(incoming_bucket_name, incoming_blob_path, ARCHIEVE_BUCKET, archive_blob_path)

    except Exception as e:
        log_message = "Error in main class uploading file {} to bigquery with upload date {}: {}".format(filename, datetime.now().strftime('%Y%m%d%H%M%S'), str(e)) 
        print(log_message)
