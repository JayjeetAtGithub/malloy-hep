import duckdb
import time
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns


if __name__ == "__main__":
    result_data = list()

    for query_no in [1, 2, 3]:
        print('Running query {}'.format(query_no))
        with open('malloy_query/q{}.sql'.format(query_no), 'r') as f:
            malloy_sql = f.read()
        
        for i in range(5):
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
        
        for i in range(5):
            s = time.time()
            res = duckdb.sql(sql)
            print(res)
            e = time.time()
            print("Time: ", e-s)
            result_data.append({
                'query_no': query_no,
                'runtime': e-s,
                'type': 'malloy'
            })

    df = pd.DataFrame(result_data)
    sns.barplot(x='query_no', y='runtime', hue='type', data=df)
    plt.savefig('result.pdf')
