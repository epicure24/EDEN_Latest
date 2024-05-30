

import csv
import sys
import os
import numpy as np
import math
import itertools
import pandas as pd
import functools
import operator
import ntpath
import concurrent.futures
import psutil
import gc
import time

def prepareTrace(trace, countDict, inputDirectory, outputDirectory):
    user=trace.split('.')[0]
    inputFile=os.path.join(inputDirectory, trace)
    df = pd.read_csv(inputFile)
    df['timestamp'] = pd.to_datetime(df['timestamp'])
    df['timestamp']=df['timestamp'].apply(lambda x : int(round(x.timestamp())))
    outputFile = os.path.join(outputDirectory, trace)
    df=df[['latitude', 'longitude', 'timestamp']]
    df.to_csv(outputFile, index=False, header=False)
    return countDict


directory = sys.argv[1]
outputDirectory = sys.argv[2]


# mkdir the output directory
if not os.path.exists(outputDirectory):
    os.makedirs(outputDirectory)

countDict={}

for filename in os.listdir(directory):
    if filename.endswith(".csv"):
        countDict=prepareTrace(filename, countDict, directory, outputDirectory)

#print(countDict)
