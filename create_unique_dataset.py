import duckdb

if __name__ == "__main__":

    for i in range(1, 10001):
        sql = """
            SELECT generate_random_uuid() AS uuid, * FROM '/mnt/data/hep.{i}.parquet'
        """
        df = duckdb.sql(sql).df()
        df.to_parquet(f"/mnt/data/{i}.parquet")

