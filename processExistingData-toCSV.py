# Title: Collected Data Normaliser
# Description: Fetches the data that has already been 
# 	received from the Monnit servers from the SQL DB 
# 	and processes it into it's normalised form using 
# 	the updated model.
#	Processed data is saved to CSV and XLSX.
# Author: Ethan Bellmer
# Date: 05/08/2020
# Version: 2.0


# Import libraries
import sys
import json
import pandas as pd
import numpy as np
import os
import traceback
import datetime

import pyodbc

from uuid import UUID

# Import the main webhook file so its functions can be used. 
import app
from app import dbConnect, split_dataframe_rows, rmTrailingValues, filterNetwork


# Variables
# SQL Server connection info
with open("./config/.dbCreds.json") as f:
	dbCreds = json.load(f)

# Formatted connection string for the SQL DB.
SQL_CONN_STR = 'DSN='+dbCreds['SERVER']+';Database='+dbCreds['DATABASE']+';Trusted_Connection=no;UID='+dbCreds['UNAME']+';PWD='+dbCreds['PWD']+';'

# Directory to save CSV and XLSX files to.
CSV_DIR = os.getcwd() + '/data/csv/'
XLSX_DIR = os.getcwd() + '/data/xlsx/'

pivotValues = ['rawData', 'dataValue', 'plotValues']
pivotIndex = ['sensorID']
pivotColumns = ['dataType', 'plotLabels']
pivotAggFunc = "np.sum"


# Functions
# Filter the data to remove any data that isn't from the MOVE network
def filterNetwork(pdDF):
	print('Filtering out unused network data')
	pdDF = pdDF[splitDf.networkID == 58947]
	return pdDF

# Split the data by sensor ID and export the data to separate CSV 
# 	files and an XLSX file with separate worksheets per sensor
def sortSensors(df):
	print('Sorting and cleaning sensors')
	# Sort the values in the dataframe by their sensor ID
	df.sort_values(by = ['sensorID'], inplace = True)
	# Set the DF index to the sensor IDs
	df.set_index(keys = ['sensorID'], drop = False, inplace = True)
	# Remove existing index names
	df.index.name = None
	return df

# Pivot passed in DF to make analysis easier. 
# 'values', 'index', and 'columns', are all lists of variables
def pivotTable(df, values, index, columns, aggFunc):
	# convert the pulled data to a pivot table to make analysis easier
	#df = pd.pivot_table(df, values=['rawData', 'dataValue', 'plotValues'], index=['sensorID'], columns=['dataType', 'plotLabels'], aggfunc=np.sum)
	df = pd.pivot_table(df, values=values, index=index, columns=columns, aggfunc=aggFunc)
	return df 

# Export passed in DF to XLSX files
def toXLSX(df, sensorID):
	print('Exporting Sensor data to XLSX')
	with pd.ExcelWriter(XLSX_DIR + 'sensorDataSplitPivot.xlsx', mode='a') as writer: # pylint: disable=abstract-class-instantiated
		# Export the data to a single XLSX file with a worksheet per sensor 
		df.to_excel(writer, sheet_name = str(sensorID))
		#writer.save

# Export the data to separate CSV files
def toCSV(df, sensorID):
	print('Exporting Sensor data to CSV')
	p = os.path.join(CSV_DIR, "sensor_{}.csv".format(sensorID))
	df.to_csv(p, index=False)


# Main Body
# Create a new DB object
conn = dbConnect()
# Create a new cursor from established DB connection
cursor = conn.cursor()

# Select all the data stored in the old DB form
SQL = "SELECT TOP(200) * FROM salfordMove.dbo.sensorData"

print('Getting data from DB')
oldData = pd.read_sql(SQL,conn)

# Delimeters used in the recieved data
delimeters = "%2c","|","%7c"
# The columns that need to be split to remove concatonated values
sensorColumns = ["rawData", "dataValue", "dataType", "plotValues", "plotLabels"]
# Split the dataframe to move concatonated values to new rows
print('Splitting DataFrame')
splitDf = split_dataframe_rows(oldData, sensorColumns, delimeters)


# Use the Pandas 'loc' function to find and replace pending changes in the dataset
print('Converting Pending Changes')
splitDf.loc[(splitDf.pendingChange == 'False'), 'pendingChange'] = 0
splitDf.loc[(splitDf.pendingChange == 'True'), 'pendingChange'] = 1


# Split the dataframe into separate dataframes by sensorID
for i, x in splitDf.groupby('sensorID'):
	# Pass the loaded dataframe into a function that will filter out any networks that don't involve MOVE
	filteredDF = filterNetwork(x)
	# Sort the dataframe by sensorID and remove index names
	filteredDF = sortSensors(filteredDF)
	# Convert the dataframe to a pivot table 
	filteredDF = pivotTable(filteredDF, pivotValues, pivotIndex, pivotColumns, pivotAggFunc)

	# Export the processed data
	toXLSX(filteredDF, i)
	toCSV(filteredDF, i)

# Close DB connection
conn.close()