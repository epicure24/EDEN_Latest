import os
import sys

import pandas as pd


def createData(input_directory,flag):
    if flag == 'train':
        output_directory = 'new_input_files/train_data/'
    else:
        output_directory = 'new_input_files/test_data/'
    for i in os.listdir(input_directory):
        if i.startswith('.ipynb_checkpoints'):
            continue
        df = pd.read_csv(input_directory+i)
        user = i.split('.')[0]
#         df['timestamp'] = pd.to_datetime(df['timestamp'])
#         df['timestamp'] = df['timestamp'].apply(lambda x : int(round(x.timestamp())))
        df['id'] = [user]*len(df)
        df = df[['user_id', 'latitude', 'longitude', 'timestamp']]
        df.to_csv(output_directory+i, index=False, header=False)
        
        
train_input_directory = sys.argv[1]
test_input_directory = sys.argv[2]


createData(train_input_directory, "train")
createData(test_input_directory, "test")
