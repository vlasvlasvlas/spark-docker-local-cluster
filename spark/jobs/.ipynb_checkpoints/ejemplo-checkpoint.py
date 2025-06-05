from pyspark.sql import SparkSession

spark = SparkSession.builder.appName("EjemploDocker").getOrCreate()
df = spark.range(1000000).withColumnRenamed("id", "numero")
df.selectExpr("numero", "numero * 2 as doble").show(10)
spark.stop()