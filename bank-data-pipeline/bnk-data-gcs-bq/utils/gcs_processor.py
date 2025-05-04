import os
import logging
from google.cloud import storage, exceptions


class GCSProcessor(object):
  
    def file_name_substring(self, split_string, filepath):
        try:
            """Get name after split_string occurrence"""
            file_name_only = filepath.split(split_string)[-1]
            logging.info(f"File name without any folder is {file_name_only} ")

            return file_name_only
        except Exception as e:
            logging.error(f"Error Message : There is an exception in file_name_substring() method {str(e)}, Alert : GCS-001")
            raise e


    def download_blob_content(self, bucket_name, filepath):
        try:
            """Downloads a blob from the bucket"""
            storage_client = storage.Client()
            bucket = storage_client.get_bucket(bucket_name)
            blob = bucket.blob(filepath)
            blob_content = blob.download_as_string()
            logging.info(f"Blob {filepath} downloaded.")

            return blob_content
        except exceptions as e:
            logging.error(f"There is an exception in download_blob_content() method {str(e)}, Alert : GCS-002")
            raise e
    
    def gcs_copy_blob(self, source_bucket_name, source_blob_name, destination_bucket_name, destination_blob_name):
        """Copies a blob from one bucket to another"""
        storage_client = storage.Client()
        source_bucket = storage_client.get_bucket(source_bucket_name)
        source_blob = source_bucket.blob(source_blob_name)
        try:
            destination_bucket = storage_client.get_bucket(destination_bucket_name)
            blob_copy = source_bucket.copy_blob(source_blob, destination_bucket, destination_blob_name)
            logging.info(f"File is copied successfully from {source_bucket_name}/{source_blob_name} to {destination_bucket_name}/{destination_blob_name} ")
        except exceptions.NotFound as e:
            logging.error(f"Error Message : There is an exception in gcs_copy_blob() method {str(e)} ")
            raise e
        except exceptions as e:
            logging.error(f"Error Message : There is an exception in gcs_copy_blob() method {str(e)}, Alert : GCS-003")
            raise e

    def gcs_delete_blob(self, bucket_name, blob_name):
        """Deletes a blob from the bucket"""
        try:
            storage_client = storage.Client()
            bucket = storage_client.bucket(bucket_name)
            blob = bucket.blob(blob_name)
            blob.delete()
            logging.info(f"Blob { blob_name } deleted from bucket { bucket_name }")
        except exceptions as e:
            logging.error(f"Error in gcs_delete_blob() method {str(e)}, Alert : GCS-003")
            raise e