import time
import duckdb
import pandas

if __name__ == "__main__":
    s = time.time()
    for i in range(1, 10000):
        sql = f"""
            SELECT gen_random_uuid()::varchar AS uid, * FROM '../hep.parquet'
        """
        res = duckdb.sql(sql)
    e = time.time()
    print("Time with UUID: ", e-s)
    t1 = e-s
    
    s = time.time()
    for i in range(1, 10000):
        sql = f"""
            SELECT * FROM '../hep.parquet'
        """
        res = duckdb.sql(sql)
    e = time.time()
    print("Time without UUID: ", e-s)
    t2 = e-s

    print("Speedup: ", t1/t2)
