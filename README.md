# **B2C Transactional Data Pipeline with AWS, Terraform, and Airflow**

## **📌 Project Overview**
This project demonstrates an **end-to-end ETL pipeline** for **Business-to-Customer (B2C) transaction data** using:
- **Terraform** for Infrastructure as Code (IaC) on AWS  
- **Amazon S3** as staging storage  
- **Amazon Redshift** as the data warehouse  
- **Apache Airflow** for orchestration  
- **Faker** for synthetic data generation  

The pipeline:
1. **Generates synthetic B2C transaction data** with Faker in Python.  
2. **Saves the data to S3** in **Parquet** format using AWS Wrangler and `boto3` for the session..  
3. **Loads data from S3 to Amazon Redshift** using Airflow's `S3ToRedshiftOperator`.  
4. **Automates infrastructure provisioning** (VPC, subnets, IAM roles, S3 buckets, Redshift cluster) via Terraform.  

---

## **🛠 Tech Stack**
- **Infrastructure:** Terraform, AWS (VPC, S3, IAM, Redshift)  
- **Data Orchestration:** Apache Airflow (CeleryExecutor, Redis, PostgreSQL backend)  
- **Data Generation:** Python, Faker, Pandas, AWS Wrangler  
- **Containerization:** Docker, Docker Compose  
- **Programming Languages:** Python, HCL (Terraform)  

---

## **📂 Project Structure**
```plaintext
.
├── dags/
│   └── b2c_dags.py               # Airflow DAG definition
│   └── b2c_trans_data.py         # Python script to generate synthetic data
├── terraform/
│   ├── main.tf                   # AWS resources definition
|    └── redshift_vpc_stack.tf 
│   └── variables.tf              # Terraform variables
|    └── provider.tf
|    └── backend.tf
|    └── s3_bucket.tf
├── Dockerfile                    # Custom Airflow image
├── docker-compose.yaml           # Airflow multi-service deployment
├── requirements.txt              # Python dependencies





└── README.md

