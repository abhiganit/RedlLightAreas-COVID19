import pandas as pd
import numpy as np
from mat4py import loadmat
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.gridspec import GridSpec


locations =  ['Mumbai','Nagpur','Delhi','Kolkata','Pune','India'];

R0 = ['R0=1.75','R0=2','R0=2.25','R0=2.5']

# column names for all population
ScenariosC = ['No initial lockdown,Citywide',
              'Return to status quo after lockdown,Citywide',
              'Coninued closure of Red light area after lockdown,Citywide']

# column names for red light area
ScenariosR = ['No initial lockdown,Red light area',
              'Return to status quo after lockdown,Red light area',
              'Coninued closure of Red light area after lockdown,Red light area']

iterablesC = [R0,ScenariosC]
iterablesR = [R0,ScenariosR]

# dataframe header for all population
colsC = pd.MultiIndex.from_product(iterablesC,names=['R0','Scenarios'])
# dataframe header for red light area
colsR = pd.MultiIndex.from_product(iterablesR,names=['R0','Scenarios'])

# column names for summary statistics
Scenarios1 = ['No initial lockdown',
              'Return to status quo after initial lockdown',
              'Coninued closure of ed light area after initial lockdown']
iterables1 = [R0,Scenarios1]
# dataframe header for summary statistics
cols1 = pd.MultiIndex.from_product(iterables1,names=['R0','Scenarios'])
variables = ['Cases','CasesPC','CumCases','Deaths','Hosp',
             'CasesR','CasesRPC','CumCasesR','DeathsR','HospR']
var_names =['Cases',
            'Cases per 1000',
            'Cumulative cases',
            'Cumulative deaths',
            'Hospitalization',
            'Cases in RLA',
            'Cases per 1000 in RLA',
            'Cumulative cases in RLA',
            'Cumulative deaths in RLA',
            'Hospitalization in RLA']

temp = dict(zip(variables,var_names))
# Save cases and per capita cases in city and RLA
D = {}
ind = (pd.date_range(start='24/03/2020',end='23/03/2021')).date
for location in locations:
    dd = {};
    writer = pd.ExcelWriter('Data_RLA/'+location+'.xlsx', engine='xlsxwriter')
    data = loadmat(location+'.mat')
    for key in variables[:5]:
        df = pd.DataFrame(np.array((data[key])),columns =colsC,index=ind)
        df.to_excel(writer,sheet_name =temp[key])
        dd[key] = df
    for key in  variables[5:]:
        df = pd.DataFrame(np.array((data[key])),columns =colsR,index=ind)
        df.to_excel(writer,sheet_name =temp[key])
        dd[key] = df
    writer.save()
    D[location] = dd

## Change names of columns for excel sheets
D = {}
ind = (pd.date_range(start='24/03/2020',end='23/03/2021')).date
for location in locations:
    dd = {};
    writer = pd.ExcelWriter('Data_RLA/'+location+'.xlsx', engine='xlsxwriter')
    data = loadmat(location+'.mat')
    for key in variables[:5]:
        df = pd.DataFrame(np.array((data[key])),columns =colsC,index=ind)
        df.to_excel(writer,sheet_name =temp[key])
        dd[key] = df
    for key in  variables[5:]:
        df = pd.DataFrame(np.array((data[key])),columns =colsR,index=ind)
        df.to_excel(writer,sheet_name =temp[key])
        dd[key] = df
    writer.save()
    D[location] = dd


# Plot relevant results
# Figure 1
plt.close('all')
RN = ['R0=1.75','R0=2','R0=2.25','R0=2.5' ]
yl = ['Cases per thousands','Cases','Deaths']
tl = ['Infections','Hospitalization in red light area',
      'Deaths in red light area']
for location in locations:
    r0 = RN[2]
    fig = plt.figure(figsize=(16,10))
    gs = GridSpec(2,2)
    ax1 = fig.add_subplot(gs[0, :])
    ax2 = fig.add_subplot(gs[1, 0])
    ax3 = fig.add_subplot(gs[1, 1])
    cls = ['k','b','g']
    sty = ['ko','bo','go']
    D[location]['CasesPC'][r0].plot(ax=ax1,color=cls)
    D[location]['CasesRPC'][r0].iloc[::3,:].plot(ax=ax1,style=sty,ms=3)
    D[location]['HospR'][r0].plot(ax=ax2,style=sty,ms=3)
    D[location]['DeathsR'][r0].plot(ax=ax3,style=sty,ms=3)
    for i, aa in enumerate([ax1,ax2,ax3]):
        aa.spines['right'].set_visible(False)
        aa.spines['top'].set_visible(False)
        aa.set_xlabel('Days',fontsize=16)
        aa.set_ylabel(yl[i],fontsize=16)
        aa.legend(frameon=False,loc='best')
        aa.set_title(tl[i],fontsize=16)

    fig.savefig('Plots/'+location + r0[3:]+'.png',bbox_inches="tight")

# summary data
data = loadmat('summary.mat')
writer = pd.ExcelWriter('Summary.xlsx',engine='xlsxwriter')
cols = ['R0=1.75','R0=2','R0=2.25','R0=2.5']
ind = locations
stats = ['Delay in peak','Cases averted at peak','Cases linked to red light area','Deaths linked to red light area']
D = {}
temp = dict(zip(data.keys(),stats))
for key in data.keys():
    df = pd.DataFrame(np.array((data[key])),columns =cols,index=ind)
    df.to_excel(writer,sheet_name =temp[key])
    D[temp[key]] = df

writer.save()


# Summary plot
stats = ['Delay in peak','Cases averted at peak','Cases linked to red light area','Deaths linked to red light area']
yl = ['Days','Cases','Cases','Deaths']
rang = ['#fd8d3c','#e6550d','#a63603']
plt.close('all')
fig,ax = plt.subplots(4,1,figsize=(16,10),sharex=True)
for i,name in enumerate(stats):
    D[name][cols[1:]].plot(kind='bar',ax=ax[i],legend=False,
                           rot=0,fontsize=16,color=rang)

for i,aa in enumerate(ax):
    aa.set_ylabel(yl[i],fontsize=16)
    aa.set_title(stats[i],fontsize=16)
    aa.spines['right'].set_visible(False)
    aa.spines['top'].set_visible(False)

handles,labels = ax[0].get_legend_handles_labels()
fig.legend(handles, labels, loc='center right',frameon=False,fontsize=16)
fig.savefig('stats.png',bbox_inches='tight')
