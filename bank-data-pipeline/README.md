# Bank Data Pipeline

This project is designed to process banking data by ingesting files from Google Cloud Storage (GCS), validating the data, and loading it into BigQuery for further analysis. The pipeline is implemented using Python and Google Cloud services.

---

## High-Level Architecture

```plaintext
+-------------------+       +-------------------+       +-------------------+
|                   |       |                   |       |                   |
| Google Cloud      |       | Python Functions  |       | Google BigQuery   |
| Storage (GCS)     | ----> | (Cloud Functions) | ----> | (Data Warehouse)  |
|                   |       |                   |       |                   |
+-------------------+       +-------------------+       +-------------------+

