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


scenarios = ['L','L+C']
R0D = ['$$R_0=1.75$$','$$R_0=2$$', '$$R_0=2.25$$', '$$R_0=2.5$$']
iterables = [scenarios,R0D]

cols = pd.MultiIndex.from_product(iterables)

writer = pd.ExcelWriter('Data_RLA/summaryA.xlsx',engine='xlsxwriter')
for idx in range(len(variablesL)):
    df = pd.DataFrame(index=locations,columns=cols)
    df['L'] = np.rint(np.array(data[variablesL[idx]]))
    df['L+C'] = np.rint(np.array(data[variablesL[idx]])+
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




stats = ['CumCases','CumHosp','CumICU','CumDeaths']
statsR = ['CumCasesR','CumHospR','CumICUR','CumDeathsR']

# Cumulative numbers
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
        dfC = D[location][stats[id]][r0]
        dfR = D[location][statsR[id]][r0]
        dfC.plot(ax=ax,color=cls)
        #dfR.iloc[::3,:].plot(ax=ax,style=sty,ms=3)
        ax.spines['right'].set_visible(False)
        ax.spines['top'].set_visible(False)
        ax.set_xlabel('Days',fontsize=20)
        #ax.set_ylabel(yl[id],fontsize=16)
        #ax.set_xlim(dfC.index[0],dfC.iloc[:,2].idxmax())
        ax.set_title(tl[id],fontsize=20)
        ax.tick_params(axis='both',which='major',labelsize=14)
        if id < 3:
            ax.legend([])
        else:
            ax.legend(ll,frameon=False,bbox_to_anchor=(-0.05, -1.1),
                      loc='lower left',fontsize=16,ncol=2)
    fig.text(-0.03,0.5,'Cumulative',va = 'center',rotation='vertical',
             fontsize=20)
    fig.suptitle(location,x=0.1,y=1,fontsize=20)
    fig.tight_layout()
    fig.savefig('Plots/'+ 'Cum_'+location + r0[3:]+'.png',bbox_inches="tight")
