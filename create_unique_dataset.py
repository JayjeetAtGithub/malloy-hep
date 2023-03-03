import os

import duckdb
import pandas

if __name__ == "__main__":
    os.rmdir("/mnt/data/dataset_uuid")
    os.makedirs("/mnt/data/dataset_uuid", exist_ok=True)
    for i in range(1, 10001):

        sql = """
            SELECT generate_random_uuid() AS uuid, * FROM '/mnt/data/dataset/hep.{i}.parquet'
        """
        df = duckdb.sql(sql).df()
        filepath = f"/mnt/data/dataset_uuid/hep.uuid.{i}.parquet"
        df.to_parquet(filepath)
        print("Wrote ", filepath)
