import os
import io
import logging
import pandas as pd
import functions_framework
from cloudevents.http import CloudEvent
import google.cloud.logging_v2.client as cloud_logging
from utils.gcs_processor import GCSProcessor
from utils.load_bigquery import load_data_bigquery

from datetime import datetime, date

PROJECT_ID = os.environ.get("PROJECT_ID")
FILE_ENCODING = os.environ.get("file_encoding", "utf-8")
SPLITTER   = os.environ.get("SPLITTER", None)
DATESET = os.environ.get("DATASET")
REGION = os.environ.get("REGION")
ARCHIEVE_BUCKET = os.environ.get("ARCHIEVE_BUCKET")
function_name = os.environ.get('K_SERVICE', 'Not set')

gcs_processor = GCSProcessor()
client =cloud_logging.Client().setup_logging()

@functions_framework.cloud_event
def data_loading(cloud_event: CloudEvent):
    filename = ""
    try:
        logging.info("Start the pipeline to process the file")

        event = cloud_event.data
        incoming_bucket_name = event['bucket']
        incoming_blob_path = event['name']
        logging.info(f"Loading data from bucket {incoming_bucket_name} and path {incoming_blob_path} ")

        filename = gcs_processor.file_name_substring("/", incoming_blob_path)

        if filename.lower().endswith(".csv"):
            logging.info(f"File from the bucket is CSV : {filename}")
            payload = gcs_processor.download_blob_content(incoming_bucket_name, incoming_blob_path)
            payload_io = io.StringIO(payload.decode(FILE_ENCODING))
            payload_io.seek(0)
            timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
            csv_input = pd.read_csv(payload_io, sep=SPLITTER, dtype=str)
            csv_input['FILE_NAME'] = filename
            csv_input['FETCH_DATE'] = timestamp

            logging.info("Start Load Data Info: File: {}, Rows: {}, Columns: {}, Splitter: ({})".format(filename,len(csv_input), len(csv_input.columns), SPLITTER))

            load_data_bigquery(PROJECT_ID, DATESET, csv_input)
            logging.info("Raw file {} successfully uploaded to bigquery".format(filename))
            archive_blob_path = f"success/{(date.today()).strftime('%Y%m%d')}/{timestamp}_{filename}"

        else:
            logging.info(f"File from the bucket is not CSV : {filename}")
            timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
            archive_blob_path = f"fail/{(date.today()).strftime('%Y%m%d')}/{timestamp}_{filename}"
            logging.error(f"Error Message : There is an exception in the main class : The file {filename} is not CSV, Alert : MN-002")
    
        gcs_processor.gcs_copy_blob(incoming_bucket_name, incoming_blob_path, ARCHIEVE_BUCKET, archive_blob_path)
        gcs_processor.gcs_delete_blob(incoming_bucket_name, incoming_blob_path)
        logging.info("Execution of {function_name} is finished successfully.")

    except Exception as e:
        if filename is not None:
            archive_blob_path = f"fail/{(date.today()).strftime('%Y%m%d')}/{timestamp}_{filename}"
            gcs_processor.gcs_copy_blob(incoming_bucket_name, incoming_blob_path, ARCHIEVE_BUCKET, archive_blob_path)
            gcs_processor.gcs_delete_blob(incoming_bucket_name, incoming_blob_path)
        logging.error("Error Message : Error in main class uploading file {} to bigquery with upload date {}: {}, Alert : MN-001".format(filename, datetime.now().strftime('%Y%m%d%H%M%S'), str(e)))
        logging.info("Execution of {function_name} is failed.")

