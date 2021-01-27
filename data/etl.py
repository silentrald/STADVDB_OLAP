# Desc: Converts the dataset to a fit in the database schema

# INIT
import pandas as pd
import numpy as np
import psycopg2
from sqlalchemy import create_engine
from sys import argv

# HELPER FUNCTION
def to_dict(arr):
    return dict(zip(arr, [x + 1 for x in range(len(arr))]))

orders = pd.DataFrame()

# Database
engine = create_engine('postgresql+psycopg2://stadvdb_user:password@127.0.0.1/stadvdb_db2', pool_recycle=3600)
conn   = engine.connect()

# Database Helper
def colission_nothing(table, conn, keys, data_iter):
    keys = ', '.join(keys)
    for row in data_iter:
        sql = "SELECT setval('{}_id_seq', MAX(id)) FROM {};".format(table.name, table.name)
        conn.execute(sql)

        if len(row) > 1:
            sql = 'INSERT INTO {}({}) VALUES {} ON CONFLICT DO NOTHING;'.format(table.name, keys, row)
        else:
            sql = "INSERT INTO {}({}) VALUES ('{}') ON CONFLICT DO NOTHING;".format(table.name, keys, row[0])
        conn.execute(sql)

def export_retrieve(df, table_name):
    df.to_sql(table_name, conn, index=False, if_exists='append', method=colission_nothing)
    return pd.read_sql('SELECT * FROM {} ORDER BY id;'.format(table_name), conn)

if len(argv) < 2:
    df = pd.read_csv('sales_data_sample.csv')
else:
    # argv[1] == filename
    df = pd.read_csv(argv[1])

# Change NaN to WEST
df['TERRITORY'] = df['TERRITORY'].fillna('WEST')

df = df.rename(
    columns={
        'YEAR_ID': 'year',
        'QTR_ID': 'quarter',
        'MONTH_ID': 'month',
        'TERRITORY': 'territory',
        'COUNTRY': 'country',
        'CITY': 'city',
        'STATUS': 'status',
        'PRODUCTLINE': 'product_line',
        'PRODUCTCODE': 'product_code',
    })

##### PERIOD DIMENSION
# Get all the data at YEAR_ID, QTR_ID, MONTH_ID
# and convert them to year, quarter, month
periods = df[['year', 'quarter', 'month']]
periods = periods.groupby(['year', 'quarter', 'month'], as_index=False).last()
periods = export_retrieve(periods, 'periods')

# Map it to orders
periods['key'] = periods['year'].map(str) + '-' + periods['quarter'].map(str) + '-' + periods['month'].map(str)
period_dict = to_dict(periods['key'])

orders['period_id'] = df['year'].map(str) + '-' + df['quarter'].map(str) + '-' + df['month'].map(str)
orders['period_id'] = orders['period_id'].map(period_dict)

##### TERRITORY DIMENSION
territory = { 'name': df['territory'].unique() }

territories = pd.DataFrame(territory)
territories = export_retrieve(territories, 'territories')

country = { 'name': df['country'].unique() }

countries = pd.DataFrame(country)
countries = export_retrieve(countries, 'countries')

city = { 'name': df['city'].unique() }

cities = pd.DataFrame(city)
cities = export_retrieve(cities, 'cities')

# Get their mapping values
territories_dict = to_dict(territory['name'])
countries_dict = to_dict(country['name'])
cities_dict = to_dict(city['name'])

territory_s = df['territory'].map(territories_dict)
country_s = df['country'].map(countries_dict)
city_s = df['city'].map(cities_dict)

location_dict = {
    'territory_id': territory_s,
    'country_id': country_s,
    'city_id': city_s
}

locations_n = pd.DataFrame(location_dict)

locations = locations_n.groupby(['territory_id', 'country_id', 'city_id'], as_index=False).last()
locations = export_retrieve(locations, 'locations')

# Map it to orders
locations['key'] = locations['territory_id'].map(str) + '-' + locations['country_id'].map(str) + '-' + locations['city_id'].map(str)
locations_dict = to_dict(locations['key'])

orders['location_id'] = locations_n['territory_id'].map(str) + '-' + locations_n['country_id'].map(str) + '-' + locations_n['city_id'].map(str)
orders['location_id'] = orders['location_id'].map(locations_dict)

##### Order Details Dimension
product_line = { 'name': df['product_line'].unique() }

product_lines = pd.DataFrame(product_line)
product_lines = export_retrieve(product_lines, 'product_lines')

product_code = { 'name': df['product_code'].unique() }

product_codes = pd.DataFrame(product_code)
product_codes = export_retrieve(product_codes, 'product_codes')

product_line_dict = to_dict(product_lines['name'])
product_code_dict = to_dict(product_codes['name'])

product_line_s = df['product_line'].map(product_line_dict)
product_code_s = df['product_code'].map(product_code_dict)

order_details_dict = {
    'product_line_id': product_line_s,
    'product_code_id': product_code_s
}

order_details_n = pd.DataFrame(order_details_dict)
order_details = order_details_n.groupby(['product_line_id', 'product_code_id'], as_index=False).last()
order_details = export_retrieve(order_details, 'order_details')

order_details['key'] = order_details['product_line_id'].map(str) + '-' + order_details['product_code_id'].map(str)
order_details_dict = to_dict(order_details['key'])

orders['order_detail_id'] = order_details_n['product_line_id'].map(str) + '-' + order_details_n['product_code_id'].map(str)
orders['order_detail_id'] = orders['order_detail_id'].map(order_details_dict)

##### ORDERS FACT
orders['sales'] = df['SALES']
orders = export_retrieve(orders, 'orders')
print('NEW DATASET')
print(orders)

conn.close()