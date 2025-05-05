from google.cloud import bigquery
import pandas as pd
import logging


def load_data_bigquery(project_id, dataset_id,  data: pd.DataFrame):
    try:
        client = bigquery.Client()

        table_id = f"{project_id}.{dataset_id}.bank_trans_raw_temp_table"
        job_config = bigquery.LoadJobConfig(
            write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
            autodetect=True,
            )
        load_job = client.load_table_from_dataframe(data, table_id, job_config=job_config)   # API request
        logging.info("Insert finished. Loaded {} rows.".format(len(data)))
    except Exception as e:
        logging.error(f"Error Message : Error in load_data_bigquery() method {str(e)}, Alert : BQ-001")
        raise e 

