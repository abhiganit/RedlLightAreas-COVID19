import pandas as pd
import numpy as np
from mat4py import loadmat
import matplotlib.pyplot as plt
import seaborn as sns
from matplotlib.gridspec import GridSpec

locations =  ['Mumbai','Nagpur','Delhi','Kolkata','Pune','India'];

R0 = ['R0=1.75','R0=2','R0=2.25','R0=2.5']

# column names for all population
Scenarios = ['No initial lockdown',
              'Return to status quo after lockdown',
              'Coninued closure of Red light area after lockdown']


iterables = [R0,Scenarios]

# dataframe header for all population
cols = pd.MultiIndex.from_product(iterables,names=['R0','Scenarios'])

variables = ['Cases','CumCases','Hosp','CumHosp',
             'ICU','CumICU','Deaths','CumDeaths',
             'CasesR','CumCasesR','HospR','CumHospR',
             'ICUR','CumICUR','DeathsR','CumDeathsR']
var_names = ['Cases','Cumulative cases',
             'Hospitalization','Cumulative hospitalization',
             'ICU','Cumulative ICU',
             'Deaths','Cumulative Deaths',
             'Cases in RLA','Cumulative cases in RLA',
             'Hospitalization in RLA',
             'Cum. hosp. in RLA',
             'ICU in RLA',
             'Cumulative ICU in RLA',
             'Deaths in RLA',
             'Cumulative Deaths in RLA']

temp = dict(zip(variables,var_names))
# Save cases and per capita cases in city and RLA
D = {}
ind = (pd.date_range(start='24/03/2020',end='23/03/2021')).date
for location in locations:
    dd = {};
    writer = pd.ExcelWriter('Data_RLA/'+location+'.xlsx', engine='xlsxwriter')
    data = loadmat(location+'.mat')
    for key in variables:
        df = pd.DataFrame(np.array((data[key])),columns =cols,index=ind)
        df.to_excel(writer,sheet_name =temp[key])
        dd[key] = df
    writer.save()
    D[location] = dd


# Get each locations population
PopA = {}
PopR = {}
for location in locations:
    data = loadmat(location+'.mat')
    PopA[location] = data['PopA']
    PopR[location] = data['PopR']


# Plot relevant results
# Figure 1
stats = ['Cases','Hosp','ICU','Deaths']
statsR = ['CasesR','HospR','ICUR','DeathsR']

RN = ['R0=1.75','R0=2','R0=2.25','R0=2.5' ]
yl = ['Cases per thousands','Hospitalization per thousands',
      'ICU per thousands','Deaths per 1000']
tl = ['Infections','Hospitalization','ICU admissions','Deaths']
ll = ['No initial lockdown,Citywide',
      'Return to status quo after lockdown,Citywide',
      'Coninued closure of red-light area after lockdown,Citywide',
      'No initial lockdown,Red-light area',
      'Return to status quo after lockdown,Red-light area',
      'Coninued closure of red-light area after lockdown,Red-light area']

plt.close('all')

for location in locations:
    r0 = RN[1]
    fig,axs = plt.subplots(4,1,figsize=(16,10),sharex=True)
    cls = ['k','b','g']
    sty = ['ko','bo','go']
    for id, ax in enumerate(axs):
        # if id >0:
        #     dfC = D[location][stats[id]][r0]
        #     dfR = D[location][statsR[id]][r0]
        # else:
        dfC = D[location][stats[id]][r0]
        dfR = 1000*D[location][statsR[id]][r0]/PopR[location]
        dfC.plot(ax=ax,color=cls)
        #dfR.iloc[::3,:].plot(ax=ax,style=sty,ms=3)
        ax.spines['right'].set_visible(False)
        ax.spines['top'].set_visible(False)
        ax.set_xlabel('Days',fontsize=16)
        #ax.set_ylabel(yl[id],fontsize=16)
        ax.set_title(tl[id],fontsize=16)
        if id > 0:
            ax.legend([])
        else:
            ax.legend(ll,frameon=False,bbox_to_anchor=(1.1, 1.1),
                      loc='upper right')
    fig.text(0.08,0.5,'Per thousands',va = 'center',rotation='vertical',
             fontsize=16)
    fig.savefig('Plots/'+location + r0[3:]+'.png',bbox_inches="tight")



## Make table to statistics (Impact of RLA continued closure)
location = 'India'
r0 = RN[1]
Delay = {}
Cases_averted_at_peak = {}
Hosp_averted_at_peak = {}
ICU_averted_at_peak = {}
Deaths_averted_at_peak = {}
CumCases_averted = {}
CumHosp_averted = {}
CumICU_averted = {}
CumDeaths_averted = {}



for location in locations:
    Delay[location] = (D[location]['Cases'][r0].idxmax()[2]
                       -D[location]['Cases'][r0].idxmax()[1]).days

    Cases_averted_at_peak[location] = (D[location]['Cases'][r0].max()[1]
                                       -D[location]['Cases'][r0].max()[2])

    Hosp_averted_at_peak[location] = (D[location]['Hosp'][r0].max()[1]
                                       -D[location]['Hosp'][r0].max()[2])

    ICU_averted_at_peak[location] = (D[location]['ICU'][r0].max()[1]
                                       -D[location]['ICU'][r0].max()[2])

    Deaths_averted_at_peak[location] = (D[location]['Deaths'][r0].max()[1]
                                       -D[location]['Deaths'][r0].max()[2])


    CumCases_averted[location] = [D[location]['CumCases'][r0].iloc[90][1]-
                                  D[location]['CumCases'][r0].iloc[90][2],
                                  D[location]['CumCases'][r0].iloc[180][1]-
                                  D[location]['CumCases'][r0].iloc[180][2]]

    CumHosp_averted[location] = [D[location]['CumHosp'][r0].iloc[90][1]-
                                  D[location]['CumHosp'][r0].iloc[90][2],
                                  D[location]['CumHosp'][r0].iloc[180][1]-
                                  D[location]['CumHosp'][r0].iloc[180][2]]

    CumICU_averted[location] = [D[location]['CumICU'][r0].iloc[90][1]-
                                D[location]['CumICU'][r0].iloc[90][2],
                                D[location]['CumICU'][r0].iloc[180][1]-
                                D[location]['CumICU'][r0].iloc[180][2]]

    CumDeaths_averted[location] = [D[location]['CumDeaths'].iloc[90][1]-
                                  D[location]['CumDeaths'].iloc[90][2],
                                  D[location]['CumDeaths'].iloc[180][1]-
                                  D[location]['CumDeaths'].iloc[180][2]]

# Make bar plots?



# ## OLD
# # Figure 2
# plt.close('all')
# RN = ['R0=1.75','R0=2','R0=2.25','R0=2.5' ]
# yl = ['Cases per thousands','Cases','Deaths']
# tl = ['Infections','Hospitalization in red light area',
#       'Deaths in red light area']
# for location in locations:
#     r0 = RN[2]
#     fig = plt.figure(figsize=(16,10))
#     gs = GridSpec(2,2)
#     ax1 = fig.add_subplot(gs[0, :])
#     ax2 = fig.add_subplot(gs[1, 0])
#     ax3 = fig.add_subplot(gs[1, 1])
#     cls = ['k','b','g']
#     sty = ['ko','bo','go']
#     D[location]['CasesPC'][r0].plot(ax=ax1,color=cls)
#     D[location]['CasesRPC'][r0].iloc[::3,:].plot(ax=ax1,style=sty,ms=3)
#     D[location]['HospR'][r0].plot(ax=ax2,style=sty,ms=3)
#     D[location]['DeathsR'][r0].plot(ax=ax3,style=sty,ms=3)
#     for i, aa in enumerate([ax1,ax2,ax3]):
#         aa.spines['right'].set_visible(False)
#         aa.spines['top'].set_visible(False)
#         aa.set_xlabel('Days',fontsize=16)
#         aa.set_ylabel(yl[i],fontsize=16)
#         aa.legend(frameon=False,loc='best')
#         aa.set_title(tl[i],fontsize=16)

#     fig.savefig('Plots/'+location + r0[3:]+'.png',bbox_inches="tight")

# # summary data
# data = loadmat('summary.mat')
# writer = pd.ExcelWriter('Summary.xlsx',engine='xlsxwriter')
# cols = ['R0=1.75','R0=2','R0=2.25','R0=2.5']
# ind = locations
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
