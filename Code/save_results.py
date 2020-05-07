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

## summary
data = loadmat('summary.mat')

variablesL = ['Dcl','Pcl','Phl','Pil','Pdl','Ccl','Chl','Cil','Cdl']
variablesR = ['Dclr','Pclr','Phlr','Pilr','Pdlr','Cclr','Chlr',
              'Cilr','Cdlr']

names = ['Delay in peak','Cases averted at peak',
          'Hosp. averted at peak','ICU averted at peak',
          'Deaths averted at peak','Cumulative cases averted',
          'Cumulative hosp. averted','Cumulative ICU averted',
          'Cumulative deaths averted']


scenarios = ['Initial lockdown','Continued closure of red-light area']

iterables = [scenarios,R0]


cols = pd.MultiIndex.from_product(iterables)

writer = pd.ExcelWriter('Data_RLA/summary.xlsx',engine='xlsxwriter')
for idx in range(len(variablesL)):
    df = pd.DataFrame(index=locations,columns=cols)
    df['Initial lockdown'] = np.rint(np.array(data[variablesL[idx]]));
    df['Continued closure of red-light area'] = np.rint(np.array(data[variablesR[idx]]));
    df = df.reindex(['Mumbai','Delhi','Kolkata','Pune','Nagpur','India'])
    df.to_excel(writer,sheet_name=names[idx])
writer.save()


scenarios = ['IL','IL+C']
R0D = ['$$R_0=1.75$$','$$R_0=2$$', '$$R_0=2.25$$', '$$R_0=2.5$$']
iterables = [scenarios,R0D]

cols = pd.MultiIndex.from_product(iterables)

writer = pd.ExcelWriter('Data_RLA/summaryA.xlsx',engine='xlsxwriter')
for idx in range(len(variablesL)):
    df = pd.DataFrame(index=locations,columns=cols)
    df['IL'] = np.rint(np.array(data[variablesL[idx]]))
    df['IL+C'] = np.rint(np.array(data[variablesL[idx]])+
                         np.array(data[variablesR[idx]]))
    df = df.reindex(['Mumbai','Delhi','Kolkata','Pune','Nagpur','India'])
    df.columns = df.columns.swaplevel(0,1)
    df.sort_index(axis=1,level=0,inplace=True)
    df.to_excel(writer,sheet_name=names[idx])
writer.save()





# Plot relevant results
# Figure 1
stats = ['Cases','Hosp','ICU','Deaths']
statsR = ['CasesR','HospR','ICUR','DeathsR']

RN = ['R0=1.75','R0=2','R0=2.25','R0=2.5' ]
yl = ['Cases per thousands','Hospitalization per thousands',
      'ICU per thousands','Deaths per 1000']
tl = ['Infections','Hospitalization','ICU admissions','Deaths']
ll = ['No initial lockdown',
      'Return to status quo after lockdown',
      'Coninued closure of red-light area after lockdown',
      'No initial lockdown,Red-light area',
      'Return to status quo after lockdown,Red-light area',
      'Coninued closure of red-light area after lockdown,Red-light area']

plt.close('all')

for location in locations:
    r0 = RN[1]
    fig,axs = plt.subplots(4,1,figsize=(12,9),sharex=True)
    cls = ['k','b','g']
    sty = ['ko','bo','go']
    for id, ax in enumerate(axs):
        # if id >0:
        #     dfC = D[location][stats[id]][r0]
        #     dfR = D[location][statsR[id]][r0]
        # else:
        dfC = D[location][stats[id]][r0]/1000000
        dfR = 1000*D[location][statsR[id]][r0]/PopR[location]
        dfC.plot(ax=ax,color=cls)
        #dfR.iloc[::3,:].plot(ax=ax,style=sty,ms=3)
        ax.spines['right'].set_visible(False)
        ax.spines['top'].set_visible(False)
        ax.set_xlabel('Days',fontsize=20)
        #ax.set_ylabel(yl[id],fontsize=16)
        ax.set_xlim(dfC.index[0],dfC.iloc[:,2].idxmax())
        ax.set_title(tl[id],fontsize=20)
        ax.tick_params(axis='both',which='major',labelsize=14)
        if id < 3:
            ax.legend([])
        else:
            ax.legend(ll,frameon=False,bbox_to_anchor=(-0.05, -1.1),
                      loc='lower left',fontsize=16,ncol=2)
    fig.text(-0.03,0.5,'in million',va = 'center',rotation='vertical',
             fontsize=20)
    fig.suptitle(location,x=0.1,y=1,fontsize=20)
    fig.tight_layout()
    fig.savefig('Plots/'+location + r0[3:]+'.png',bbox_inches="tight")

















## Make table to statistics (Impact of RLA continued closure)
location = 'India'
r0 = RN[0]
Delay = {}
Cases_averted_at_peak = {}
Hosp_averted_at_peak = {}
ICU_averted_at_peak = {}
Deaths_averted_at_peak = {}
CumCases_averted90 = {}
CumCases_averted180 = {}
CumHosp_averted90 = {}
CumHosp_averted180 = {}
CumICU_averted90 = {}
CumICU_averted180 = {}
CumDeaths_averted90 = {}
CumDeaths_averted180 = {}

# stats = ['Delay','Cases averted at peak','Hospitalization averted at peak',
#          'ICU averted at peak','Deaths averted at peak',
#          'Cumulative cases averted in 90 days',
#          'Cumulative cases averted in 180 days',
#          'Cumulative hospitalization averted in 90 days',
#          'Cumulative hospitalization averted in 180 days',
#          'Cumulative ICU averted in 90 days',
#          'Cumulative ICU averted in 180 days',
#          'Cumulative deaths averted in 90 days',
#          'Cumulative deaths averted in 180 days']


iterables = [RN,stats]
cols = pd.MultiIndex.from_product(iterables,names=['R0','Scenarios'])
DD = {}

for r0 in RN:
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

        CumCases_averted90[location] = D[location]['CumCases'][r0].iloc[90][1]-D[location]['CumCases'][r0].iloc[90][2]

        CumCases_averted180[location] = D[location]['CumCases'][r0].iloc[180][1]- D[location]['CumCases'][r0].iloc[180][2]

        CumHosp_averted90[location] = D[location]['CumHosp'][r0].iloc[90][1]- D[location]['CumHosp'][r0].iloc[90][2]

        CumHosp_averted180[location] = D[location]['CumHosp'][r0].iloc[180][1]-D[location]['CumHosp'][r0].iloc[180][2]


        CumICU_averted90[location] = D[location]['CumICU'][r0].iloc[90][1]- D[location]['CumICU'][r0].iloc[90][2]


        CumICU_averted180[location] = D[location]['CumICU'][r0].iloc[180][1]- D[location]['CumICU'][r0].iloc[180][2]

        CumDeaths_averted90[location] = D[location]['CumDeaths'].iloc[90][1]- D[location]['CumDeaths'].iloc[90][2]

        CumDeaths_averted180[location] = D[location]['CumDeaths'].iloc[180][1]-D[location]['CumDeaths'].iloc[180][2]

    DD[r0] = pd.DataFrame([Delay,Cases_averted_at_peak,Hosp_averted_at_peak,ICU_averted_at_peak,Deaths_averted_at_peak,
                           CumCases_averted90,CumCases_averted180,CumHosp_averted90,CumHosp_averted180,
                           CumICU_averted90,CumICU_averted180,CumDeaths_averted90,CumDeaths_averted180]).T

Data = pd.DataFrame(columns=cols,index=locations)

for r0 in RN:
    Data[r0] = DD[r0].values

Data.to_excel('Data_RLA/summary.xlsx')
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
