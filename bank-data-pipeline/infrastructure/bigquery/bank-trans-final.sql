DECLARE PROCESSED_TIMESTAMP TIMESTAMP;
SET PROCESSED_TIMESTAMP = CURRENT_TIMESTAMP();


CREATE OR REPLACE TABLE `favorable-kiln-458413-r9.BNK_DATA.raw_bank_table`
AS
WITH raw_data AS (
  SELECT *
 FROM `favorable-kiln-458413-r9.BNK_DATA.bank_trans_raw_temp_table`
),

dup_check AS (
  select
    *,
    ROW_NUMBER() OVER (PARTITION BY raw_data.transaction_id ORDER BY raw_data.transaction_date) AS row_num
  FROM raw_data
),

data_check AS(
  select 
    *,
    CASE
      WHEN dup_check.transaction_id IS NULL THEN 'transaction_id is NULL'
      WHEN dup_check.account_id IS NULL THEN 'account_id is NULL'
      WHEN dup_check.amount IS NULL THEN 'amount is NULL'
      WHEN dup_check.transaction_type IS NULL THEN 'transaction_type is NULL'
      WHEN dup_check.transaction_date IS NULL THEN 'transaction_date is NULL'
      WHEN SAFE_CAST(dup_check.amount AS NUMERIC) IS NULL THEN 'amount is not numeric'
      WHEN SAFE.PARSE_TIMESTAMP("%Y-%m-%d %H:%M:%S", dup_check.transaction_date) is NULL THEN "Invalid transaction_date"
      WHEN LOWER(dup_check.transaction_type) NOT IN ('debit', 'credit') THEN 'Invalid transaction_type'
      WHEN LENGTH(dup_check.account_id) > 4 THEN "account id is invaild"
      WHEN dup_check.row_num >1 THEN "Duplicate transcation_id"
    END AS issue,
  FROM dup_check
)

select 
  *,
  PROCESSED_TIMESTAMP
from data_check;


CREATE OR REPLACE TABLE `favorable-kiln-458413-r9.BNK_DATA.bank_trans_error_table`
AS
SELECT 
  * 
FROM `favorable-kiln-458413-r9.BNK_DATA.raw_bank_table`
  WHERE issue is not NULL;

CREATE OR REPLACE TABLE `favorable-kiln-458413-r9.BNK_DATA.bank_clean_data`
AS
WITH clean_raw_data AS (
  SELECT
    *
  FROM `favorable-kiln-458413-r9.BNK_DATA.raw_bank_table`
    WHERE (issue is NULL OR issue not like "%Duplicate%")
      AND row_num = 1
),

clean_amnt AS (
  SELECT
    *,
    IF(SAFE_CAST(clean_raw_data.amount AS NUMERIC) IS NULL, 0, SAFE_CAST(clean_raw_data.amount AS NUMERIC)) AS amount_clean
  FROM clean_raw_data
)

  SELECT
    *,
    CASE
      WHEN LOWER(clean_amnt.transaction_type) NOT IN ('debit', 'credit') THEN 
        IF (clean_amnt.amount_clean >= 0, "credit", "debit")
      ELSE clean_amnt.transaction_type
  END AS transaction_type_clean,
  FORMAT_TIMESTAMP('%Y-%m-%d %H:%M:%S',
    CASE
      WHEN SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', clean_amnt.transaction_date) IS NOT NULL THEN SAFE.PARSE_TIMESTAMP('%Y-%m-%d %H:%M:%S', clean_amnt.transaction_date)
      WHEN SAFE.PARSE_TIMESTAMP('%d-%m-%Y %H:%M:%S', clean_amnt.transaction_date) IS NOT NULL THEN SAFE.PARSE_TIMESTAMP('%d-%m-%Y %H:%M:%S', clean_amnt.transaction_date)
      WHEN SAFE.PARSE_TIMESTAMP('%m/%d/%Y %H:%M:%S', clean_amnt.transaction_date) IS NOT NULL THEN SAFE.PARSE_TIMESTAMP('%m/%d/%Y %H:%M:%S', clean_amnt.transaction_date)
      WHEN SAFE.PARSE_TIMESTAMP('%b %d, %Y %H:%M:%S', clean_amnt.transaction_date) IS NOT NULL THEN SAFE.PARSE_TIMESTAMP('%b %d, %Y %H:%M:%S', clean_amnt.transaction_date)
      WHEN SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M:%S', clean_amnt.transaction_date) IS NOT NULL THEN SAFE.PARSE_TIMESTAMP('%Y/%m/%d %H:%M:%S', clean_amnt.transaction_date)
    END
  ) AS formatted_transaction_date,
  FORMAT_TIMESTAMP('%Y-%m-%d %H:%M:%S', PARSE_TIMESTAMP("%Y%m%d%H%M%S", FETCH_DATE)) AS FILE_FETCH_DATE
  FROM clean_amnt;

INSERT INTO `favorable-kiln-458413-r9.BNK_DATA.bank_trans_final_table`
with add_calculation AS (
  SELECT
    *,
    SUM(CAST(amount_clean AS NUMERIC)) OVER (PARTITION BY account_id
      ORDER BY formatted_transaction_date, transaction_id
    ) AS current_balance
  FROM `favorable-kiln-458413-r9.BNK_DATA.bank_clean_data`
),

matchedrecords AS (
  SELECT add_calculation.transaction_id
  from add_calculation
    LEFT JOIN `favorable-kiln-458413-r9.BNK_DATA.bank_trans_final_table` main_tab
      ON (add_calculation.transaction_id = main_tab.transaction_id)
    WHERE main_tab.transaction_id IS NOT NULL 
),

finaldata AS (
  SELECT * 
  from add_calculation
    WHERE transaction_id NOT IN (SELECT distinct transaction_id
      FROM matchedrecords)  
)

SELECT
  transaction_id,
  account_id,
  transaction_type_clean as transaction_type,
  amount_clean as amount,
  current_balance,
  formatted_transaction_date as transaction_date,
  FILE_NAME,
  FILE_FETCH_DATE,
  PROCESSED_TIMESTAMP,
FROM finaldata;


DROP TABLE `favorable-kiln-458413-r9.BNK_DATA.raw_bank_table`;
DROP TABLE `favorable-kiln-458413-r9.BNK_DATA.bank_clean_data` ;
