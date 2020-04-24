import pandas as pd
import numpy as np
from mat4py import loadmat
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.gridspec import GridSpec


locations =  ['Mumbai','Nagpur','Delhi','Kolkata','Pune','India'];

R0 = ['R0 = 1.75','R0 = 2','R0 = 2.25','R0 = 2.5']
ScenariosC = ['No initial lockdown,Citywide',
              'Return to status quo after lockdown,Citywide',
              'Coninued closure of Red light area after lockdown,Citywide']

ScenariosR = ['No initial lockdown,Red light area',
              'Return to status quo after lockdown,Red light area',
              'Coninued closure of Red light area after lockdown,Red light area']

iterablesC = [R0,ScenariosC]
iterablesR = [R0,ScenariosR]


colsC = pd.MultiIndex.from_product(iterablesC,names=['R0','Scenarios'])
colsR = pd.MultiIndex.from_product(iterablesR,names=['R0','Scenarios'])

Scenarios1 = [ 'Return to status quo after lockdown',
              'Coninued closure of Red light area after lockdown']
iterables1 = [R0,Scenarios1]
cols1 = pd.MultiIndex.from_product(iterables1,names=['R0','Scenarios'])



# Save cases and per capita cases in city and RLA
D = {}
dd = {};
for location in locations:
    writer = pd.ExcelWriter(location+'.xlsx', engine='xlsxwriter')
    data = loadmat(location+'.mat')
    for key in ['Cases','CasesPC']:
        df = pd.DataFrame(np.array((data[key])),columns =colsC)
        df.to_excel(writer,sheet_name =key)
        dd[key] = df
    for key in  ['CasesR','CasesRPC']:
        df = pd.DataFrame(np.array((data[key])),columns =colsR)
        df.to_excel(writer,sheet_name =key)
        dd[key] = df

    for key in ['CLR','DLR']:
        df = pd.DataFrame(np.array((data[key])),columns =cols1)
        df.to_excel(writer,sheet_name =key)
        dd[key] = df
    writer.save()
    D[location] = dd


# Plot relevant results
# Figure 1
plt.close('all')
RN = ['R0 = 1.75','R0 = 2','R0 = 2.25','R0 = 2.5' ]
yl = ['Cases per thousands','Cases','Deaths']
tl = ['Infections','Cases linked to red light area',
      'Deaths linked to red light area']
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
    D[location]['CLR'][r0].plot(ax=ax2,style=sty[1:],ms=3)
    D[location]['DLR'][r0].plot(ax=ax3,style=sty[1:],ms=3)
    for i, aa in enumerate([ax1,ax2,ax3]):
        aa.spines['right'].set_visible(False)
        aa.spines['top'].set_visible(False)
        aa.set_xlabel('Days',fontsize=16)
        aa.set_ylabel(yl[i],fontsize=16)
        aa.legend(frameon=False,loc='best')
        aa.set_title(tl[i],fontsize=16)

    fig.savefig(location + r0[5:]+'.png',bbox_inches="tight")

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
