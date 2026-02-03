import sys
import pandas as pd  

print('arguments',sys.argv)

month = int(sys.argv[1])
df = pd.DataFrame({'day': [1,2,3], 'num_passegers': [4,5,6]}) 
df['month'] = month
print (df.head())

df.to_parquet(f"output_{month}.parquet")

print ('hello pipeline, month =', month)