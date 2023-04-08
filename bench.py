import sys
import time

import duckdb
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


result_data = list()


def run_bench(query_no, iterations, dataset):
    print('Running query {}'.format(query_no))
    with open('malloy_query/q{}.sql'.format(query_no), 'r') as f:
        malloy_sql = f.read()
        malloy_sql = malloy_sql.format(dataset_path=dataset)
    
    for i in range(iterations):
        s = time.time()
        res = duckdb.sql(malloy_sql)
        print(res)
        e = time.time()
        print("Time: ", e-s)
        result_data.append({
            'query_no': query_no,
            'runtime': e-s,
            'type': 'malloy'
        })

    with open('sql_query/q{}.sql'.format(query_no), 'r') as f:
        sql = f.read()
        sql = sql.format(dataset_path=dataset)

    for i in range(iterations):
        s = time.time()
        res = duckdb.sql(sql)
        print(res)
        e = time.time()
        print("Time: ", e-s)
        result_data.append({
            'query_no': query_no,
            'runtime': e-s,
            'type': 'sql'
        })


if __name__ == "__main__":
    mode = str(sys.argv[1])
    dataset = str(sys.argv[2])
    
    if mode == 'e2e':
        reps = int(sys.argv[3])
        for query_no in [1, 2, 3, 4, 7]:
            run_bench(query_no, reps, dataset)
        
        df = pd.DataFrame(result_data)
        df.to_csv('result.csv')
        sns.barplot(x='query_no', y='runtime', hue='type', data=df)
        plt.savefig('result.pdf')
    elif mode == 'q':
        query_no = int(sys.argv[3])
        run_bench(query_no, 1, dataset)
