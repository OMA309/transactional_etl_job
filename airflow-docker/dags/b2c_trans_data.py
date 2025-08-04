import random
import uuid
from datetime import datetime

import awswrangler as wr
import boto3
import pandas as pd
from airflow.models import Variable
from dotenv import load_dotenv
from faker import Faker

load_dotenv()

fake = Faker()

name_generate = {
    "Male": fake.name_male,
    "Female": fake.name_female
}

product_catalogue = {

    "perishable": ["Tomatoes", "Onions", "Pepper", "Bananas", "Cucumber"],
    "snacks": ["Biscuits", "Chin Chin", "Plantain Chips", "Puff Puff", "Cake"],
    "drinks": [
        "Bottle Water", "Zobo", "Fayrouz", "Yoghurt", "Malts", "Fanta",
        "Miranda", "Pepsi", "Monster", "Lucozade boost"
    ],
    "Household": [
        "Detergent", "Toilet Roll", "Dish Soap", "Toothpaste", "Air Freshner"
    ]
}

purchase_datetime = fake.date_time()
units = ["kg", "litre", "pack", "carton", "piece"]
payment_methods = ["Cash", "POS", "Bank Transfer"]
ethnicity_categories = [
    "Black",
    "Caucasian",
    "Latino",
    "Asian",
    "Middle Eastern",
    "Native American",
    "Mixed/Other"
]


def b2c_transaction_records():
    gender = random.choice(["Male", "Female"])
    name = name_generate[gender]()
    categories = random.choice(list(product_catalogue.keys()))
    product = random.choice(product_catalogue[categories])
    quantity = random.randint(1, 50)
    unit_price = round(random.uniform(10, 500), 2)
    total_price = round(unit_price * quantity, 2)
    return {
        "transaction_id": str(uuid.uuid4()),
        "timestamp": fake.date_time(),
        "customer_name": name,
        "gender": gender,
        "age": random.randint(18, 70),
        "ethnicity": random.choice(ethnicity_categories),
        "address": fake.address().replace("\n", ","),
        "product_category": categories,
        "product_name": product,
        "unit": random.choice(units),
        "quantity": quantity,
        "unit_price_naira": f"${unit_price:,.2f}",
        "total_price_naira": f"${total_price:,.2f}",
        "payment_method": random.choice(payment_methods),
        "State_of_purchase": fake.state()
    }


def generate_b2c_data():
    b2c_data = random.randint(50, 100)
    data = []
    for records in range(b2c_data):
        records = b2c_transaction_records()
        data.append(records)
    df = pd.json_normalize(data)
    df['age'] = df['age'].astype('int32')
    df['quantity'] = df['quantity'].astype('int32') 
    session = boto3.Session(
            aws_access_key_id=Variable.get('access_key'),
            aws_secret_access_key=Variable.get('secret_key'),
            region_name=Variable.get('region'))
    date_value = datetime.today().strftime('%Y-%m-%d')
    bucket_name = "b2c-transactional-records/transactional-records"
    parquet_file = f"{date_value}_b2c-tranx.parquet"
    path_s3 = f's3://{bucket_name}/{parquet_file}'
    wr.s3.to_parquet(
        df=df,
        path=path_s3,
        dataset=True,
        mode="append",
        boto3_session=session,
        compression="snappy")

    return parquet_file
