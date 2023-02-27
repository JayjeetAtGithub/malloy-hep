import duckdb
import time
import sys

if __name__ == "__main__":

    query_no = int(sys.argv[1])
    
    with open('malloy_query/q{}.sql'.format(query_no), 'r') as f:
        malloy_sql = f.read()
    s = time.time()
    res = duckdb.sql(malloy_sql)
    print(res)
    e = time.time()
    print("Time: ", e-s)

    with open('sql_query/q{}.sql'.format(query_no), 'r') as f:
        sql = f.read()
    s = time.time()
    res = duckdb.sql(sql)
    print(res)
    e = time.time()
    print("Time: ", e-s)
