import numpy as np
import pandas as pd

# Regions to consider: Delhi (NCT), Nagpur (Maharastra), Mumbai (Maharastra), Kolkata (West Bengal)

# Reading raw data
Data = pd.read_excel('DDW-0000C-13.xls',skiprows=[0])
Data = Data[['State','Area Name','Age','Total']] # Keeping relevant columns
Data.drop([0,1,2,3,4],inplace=True) # Drop irrelevant rows
Data.set_index('State',inplace=True) # Make state codes index

# Initialize DataFrame for saving data
df = pd.DataFrame(columns=Data.index.unique())
# Group by population by grouping by each 5 years (0-4,5-9,10-14,...)
for ind in Data.index:
    temp = Data.loc[ind]
    temp = temp.iloc[1:-1]
    temp.reset_index(inplace=True)
    temp_ = temp.groupby(temp.index // 5).sum()
    temp_ = temp_['Total']
    df[ind] = temp_


df = df/df.sum()

temp = Data['Area Name'].unique()
for i in range(1,len(temp)):
    temp[i] = temp[i][8:-5]

df.columns = temp
df['TELANGANA'] = df['ANDHRA PRADESH'] # Assign same weights to Telangana as Andhra Pradesh

# Age-distribution for the the regions being considered
# df = df[['NCT OF DELHI','NCT OF DELHI',
#          'WEST BENGAL','WEST BENGAL',
#          'MAHARASHTRA','MAHARASHTRA',
#          'MAHARASHTRA','MAHARASHTRA']]

df = df[['MAHARASHTRA','MAHARASHTRA',
         'MAHARASHTRA','MAHARASHTRA',
         'NCT OF DELHI','NCT OF DELHI',
         'WEST BENGAL','WEST BENGAL',
         'MAHARASHTRA','MAHARASHTRA',
         'India','India']]
# Creating an excel with names of states
# current population in Mumbai, Mumbai_RL, Nagpur, Nagpur_RL, Delhi, Delhi_RL, Kolkata,Kolkata_RL, Pune, Pune_RL, India, India_RL
pop = [20411000,5471.4,
       2893000,2310,
       19500000,4048,
       14850000,16000,
       6629000,6345,
       1380004385,637500];
current_population = pd.Series(pop,index= df.columns)

# Save age-distributed data as excel
adf = df*current_population

adf.columns = ['Mumbai','Mumbai_RLA','Nagpur','Nagpur_RLA',
               'Delhi','Delhi_RLA','Kolkata','Kolkata_RLA',
               'Pune','Pune_RLA','India','India_RLA']


adf.to_excel('Population_distribution.xlsx')
