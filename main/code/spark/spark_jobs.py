# below code give 5 jobs 

import findspark
findspark.init()

from pyspark.sql import SparkSession
from pyspark.sql.functions import *

spark = SparkSession.builder.master("local[5]") \
    .appName("testing") \
    .getOrCreate()

employee_df = spark.read.format("csv") \
    .option("header", "true") \
    .load("D:/Training/PySpark_Practice/utils/employee_data.csv")

print(employee_df.rdd.getNumPartitions())

employee_df = employee_df.repartition(2)

print(employee_df.rdd.getNumPartitions())

employee_df = employee_df.filter(col("salary") > 90000) \
    .select("id", "name", "age", "salary") \
    .groupby("age").count()

employee_df.collect()
input("Press Enter ti terminate")
