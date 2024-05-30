

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
    df['user_id'] = [user]*len(df)
    df=df[['user_id', 'latitude', 'longitude', 'timestamp']]
    df.to_csv(outputFile, index=False, header=False)
    return countDict


def prepareTrace_for_trilateration(trace, countDict, inputDirectory, outputDirectory):
    user=trace.split('.')[0]
    inputFile=os.path.join(inputDirectory, trace)
    df = pd.read_csv(inputFile, names=['latitude', 'longitude', 'timestamp'])
    df = df.dropna().reset_index(drop=True)
#     df['timestamp'] = pd.to_datetime(df['timestamp'])
#     df['timestamp']=df['timestamp'].apply(lambda x : int(round(x.timestamp())))
    outputFile = os.path.join(outputDirectory, trace)
    df['user_id'] = [user]*len(df)
    df=df[['user_id', 'latitude', 'longitude', 'timestamp']]
    df.to_csv(outputFile, index=False, header=False)
    return countDict

directory = sys.argv[1]
outputDirectory = sys.argv[2]
lppm = sys.argv[3]


# mkdir the output directory
if not os.path.exists(outputDirectory):
    os.makedirs(outputDirectory)

countDict={}

if lppm == "geo":
    for filename in os.listdir(directory):
        if filename.endswith(".csv"):
            countDict=prepareTrace(filename, countDict, directory, outputDirectory)
else:
    for filename in os.listdir(directory):
        if filename.endswith(".csv"):
            countDict=prepareTrace_for_trilateration(filename, countDict, directory, outputDirectory)    

#print(countDict)
