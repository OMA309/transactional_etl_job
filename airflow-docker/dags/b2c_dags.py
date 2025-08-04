from datetime import datetime

from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.amazon.aws.transfers.s3_to_redshift import (
    S3ToRedshiftOperator,
)
from b2c_trans_data import generate_b2c_data

default_args = {
    'owner': 'Botafli',
    'retries': 2,
}

dag = DAG(
    dag_id="b2c_tranx_data",
    description="This is the dag for business to customers extraction to s3",
    start_date=datetime(2025, 7, 28),
    schedule_interval="@daily",
    catchup=False,
    default_args=default_args
)


b2c_tranx_dump_to_s3 = PythonOperator(
    task_id="b2c_tranx_dump_to_s3",
    python_callable=generate_b2c_data,
    dag=dag
    )
today_str = datetime.today().strftime('%Y-%m-%d')
parquet_file = f"{today_str}_b2c-tranx.parquet"

copy_b2c_parquet_to_redshift = S3ToRedshiftOperator(
    task_id="copy_b2c_parquet_to_redshift",
    schema="public",
    table="b2c_transactions",
    s3_bucket="b2c-transactional-records/transactional-records",
    s3_key=parquet_file,
    copy_options=["FORMAT AS PARQUET"],
    redshift_conn_id="redshift_default",
    aws_conn_id="aws_default",
    dag=dag
)

b2c_tranx_dump_to_s3 >> copy_b2c_parquet_to_redshift
