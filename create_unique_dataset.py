import os
import shutil

import duckdb
import pandas

if __name__ == "__main__":
    shutil.rmtree("/mnt/data/dataset_uuid", ignore_errors=True)
    os.makedirs("/mnt/data/dataset_uuid", exist_ok=True)
    for i in range(1, 10001):

        sql = f"""
            SELECT convert(varchar, gen_random_uuid()) AS uuid, * FROM '/mnt/data/dataset/hep.{i}.parquet'
        """
        df = duckdb.sql(sql).df()
        filepath = f"/mnt/data/dataset_uuid/hep.uuid.{i}.parquet"
        df.to_parquet(filepath)
        print("Wrote ", filepath)
