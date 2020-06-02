import numpy as np
import pandas as pd
import matplotlib as mpl
from matplotlib import pyplot as plt
import matplotlib.dates as mdates
from matplotlib.dates import DateFormatter
from itertools import cycle, islice

## List of Figures:
## 1. Model diagram X
## 2. Delay in the peak for R0=2  X
## 3. Cumulative cases & deaths till the peak for each location at R0=2 X
## 4. RLA burden: Percent red in 1)Cum Hosp. 2) Cum. ICU and 3) Cum. Death X
## 5. Burden of hospital capacity X

## List of Tables:
## 1. Data on RLA X
## S1. Model compartments X
## S2. Model parameters X
## S3. Delay in the peak X
## S4. Per. red. in cum. cases & deaths till the peak for each loc. and R0.X
## S5. RLA burden: Cum Cases X
## S6. RLA burden: Cum Hosp. X
## S7. RLA burden: Cum ICU. X
## S8. RLA burden: Cum deaths X

names = ['India','Kolkata','Delhi','Mumbai','Pune','Nagpur']

######################################################
# Table S3: Delay in peak for each R0 and location
scenarios = ['L','L+C']
R0 = ['R0=1.75','R0=2','R0=2.25','R0=2.5']
iterables = [R0,scenarios]
cls = pd.MultiIndex.from_product(iterables)
tableS3 = pd.DataFrame(index=names,columns=cls)

for r0 in R0:
    for name in names:
        df = pd.read_excel(name+'.xlsx',sheet_name='Cases',header=[0,1])
        pnl = df[r0]['No initial lockdown'].idxmax()
        pl = df[r0]['Return to status quo after lockdown'].idxmax()
        pr = df[r0]['Coninued closure of Red light area after lockdown'].idxmax()
        dl = pl - pnl
        dlr = pr - pnl
        tableS3[r0,'L'][name] = dl
        tableS3[r0,'L+C'][name] = dlr

tableS3.to_excel('TableS3.xlsx')

# lockdown effect in terms of delay
le = pd.DataFrame(index=names,columns=R0)
for r0 in R0:
    x = tableS3[r0]['L+C']-tableS3[r0]['L']
    le[r0] = x
########################################################

########################################################
# Figure 2: Delay in peak for R0=2 and all locations
outputs = ['L','L+C']
r0 = 'R0=2'
fig2data = pd.DataFrame(index=names,columns=outputs)
fig2data['L'] = tableS3[r0]['L']
fig2data['L+C'] = tableS3[r0]['L+C'] - tableS3[r0]['L']

# plot
# re-order names
fig2data = fig2data.iloc[::-1]
fig2data.rename(index={'Delhi':'New Delhi'},inplace=True)
lg = ['Initial lockdown','Extended RLA closure after lockdown']
plt.close('all')
fig, ax = plt.subplots(figsize=(16,8))
fig2data.plot(kind='barh',ax=ax,stacked='True',color=['#fc8d59','#2b8cbe'])
# Add legend
ax.legend(lg,frameon=False,bbox_to_anchor=(0.5,1.1),
          loc='upper center',ncol=2,fontsize=16)
# Add values as labels on bars
for rect in ax.patches:
    # Find where everything is located
    height = rect.get_height()
    width = rect.get_width()
    x = rect.get_x()
    y = rect.get_y()
    # The width of the bar is data values
    label_text = int(width)
    label_x = x+width /2
    label_y = y+height - 0.2
    ax.text(label_x,label_y,label_text,ha='right',va='center',
            color='w',fontweight='bold',fontsize=14)
ax.spines['right'].set_visible(False)
ax.spines['top'].set_visible(False)
ax.set_xlabel('Delay in the epidemic peak (in days)',fontsize=20)
ax.tick_params(axis='both',labelsize=18)
#fig.savefig('Figure2.png',bbox_inches="tight")
fig.savefig('../Plots/Figure2.png',bbox_inches="tight")
################################################################

################################################################
## Table S4: Percentage reduction in cases & deaths
outputs = ['Red in cases','Red in deaths']
iterables = [outputs,R0]
cls = pd.MultiIndex.from_product(iterables)
tableS4 = pd.DataFrame(index=names,columns=cls)
for r0 in R0:
    for name in names:
        # read cases data to calculate peak
        df = pd.read_excel(name+'.xlsx',sheet_name='Cases',header=[0,1])
        # find the time of peak under scenario of re-opening
        pl = df[r0]['Return to status quo after lockdown'].idxmax()
        # calculate cumulative cases & deaths
        dfC = pd.read_excel(name+'.xlsx',sheet_name='Cumulative cases',
                            header=[0,1])
        dfD = pd.read_excel(name+'.xlsx',sheet_name='Cumulative Deaths',
                            header=[0,1])
        # calculate cumulative cases & deaths at peak
        rsC = dfC[r0,'Return to status quo after lockdown'].iloc[pl]
        ccC = dfC[r0,'Coninued closure of Red light area after lockdown'].iloc[pl]
        rsD = dfD[r0,'Return to status quo after lockdown'].iloc[pl]
        ccD = dfD[r0,'Coninued closure of Red light area after lockdown'].iloc[pl]
        # populate table with percentage reductions
        tableS4['Red in cases',r0][name] = round((rsC-ccC)/rsC,3)
        tableS4['Red in deaths',r0][name] = round((rsD-ccD)/rsD,3)

tableS4.to_excel('TableS4.xlsx')
##################################################################

##################################################################
## Figure 3 Reduction in cumulative cases & deaths

nd = {'India':'India','Kolkata':'Kolkata',
      'Delhi':'New Delhi','Mumbai':'Mumbai',
      'Pune':'Pune','Nagpur':'Nagpur'}
r0 = 'R0=2'
# legend labels
ll = ['Reopening of RLA after lockdown',
      'Extended RLA closure after lockdown']

# format of dates
date_form = DateFormatter("%b-%d")
plt.close('all')
fig,ax = plt.subplots(6,2,figsize=(20, 20))

for id,name in enumerate(names):
    df = pd.read_excel(name+'.xlsx',sheet_name='Cases',header=[0,1])
    # Find the peak under reopening of the red-light area after lockdown
    pl = df[r0]['Return to status quo after lockdown'].idxmax()
    # read cumulative data
    dfC = pd.read_excel(name+'.xlsx',sheet_name='Cumulative cases',
                        header=[0,1])
    dfD = pd.read_excel(name+'.xlsx',sheet_name='Cumulative Deaths',
                        header=[0,1])
    # grab curve for cumulative cases and deaths
    # between the end of lockdown to the peak for R0=2
    clr = dfC[r0]['Return to status quo after lockdown'].iloc[69:pl+1]
    clc = dfC[r0]['Coninued closure of Red light area after lockdown'].iloc[69:pl+1]
    dlr = dfD[r0]['Return to status quo after lockdown'].iloc[69:pl+1]
    dlc = dfD[r0]['Coninued closure of Red light area after lockdown'].iloc[69:pl+1]
    # grab time to plot
    tt = dfC['R0'].iloc[69:pl+1]
    # grab extended time for x-axis extension
    tt_ = dfC['R0'].iloc[69:pl+5]

    # plot data per million
    ax[id,0].plot(tt,clr/1000000,'#fc8d59',tt,clc/1000000,'#2b8cbe',
                  linewidth=2.5)
    ax[id,1].plot(tt,dlr/1000000,'#fc8d59',tt,dlc/1000000,'#2b8cbe',
                  linewidth=2.5)
    # set x-lims
    ax[id,0].set_xlim(tt.iloc[0],tt_.iloc[-1])
    ax[id,1].set_xlim(tt.iloc[0],tt_.iloc[-1])

    # remove top and right spines
    ax[id,0].spines['right'].set_visible(False)
    ax[id,0].spines['top'].set_visible(False)
    ax[id,1].spines['right'].set_visible(False)
    ax[id,1].spines['top'].set_visible(False)

    # Add arrow and show percentage reduction at peak
    xt = tt.iloc[-1 ]
    cr = clr/1000000; cr = cr.iloc[-1]
    cc = clc/1000000; cc = cc.iloc[-1]
    dr = dlr/1000000; dr = dr.iloc[-1]
    dc = dlc/1000000; dc = dc.iloc[-1]

    ax[id,0].plot((xt,xt),(cr,cc),'k',linewidth=1)
    ax[id,0].plot((xt,xt),(cc,cc),'k',marker='v')
    ax[id,0].text(tt_.iloc[-3],(cr+cc)/2,
                  '-' +
                  str(round(100*(tableS4['Red in cases',r0][name]),1))+'%',
                  fontsize=16)
    ax[id,1].plot((xt,xt),(dr,dc),'k',linewidth=1)
    ax[id,1].plot((xt,xt),(dc,dc),'k',marker='v')
    ax[id,1].text(tt_.iloc[-3],(dr+dc)/2,
                  '-' +
                  str(round(100*(tableS4['Red in deaths',r0][name]),1))+'%',
                  fontsize=16)
    # format x-axis label to show month and date
    ax[id,0].xaxis.set_major_formatter(date_form)
    ax[id,1].xaxis.set_major_formatter(date_form)
    # set ylabel names
    ax[id,0].set_ylabel(nd[name],rotation='horizontal',fontsize=20)
    ax[id,0].yaxis.set_label_coords(-0.25,0.5)
    ax[id,0].tick_params(axis='both',labelcolor='k',labelsize=15)
    ax[id,1].tick_params(axis='both',labelcolor='k',labelsize=15)
    ax[id,0].xaxis.set_major_locator(plt.MaxNLocator(8))
    ax[id,1].xaxis.set_major_locator(plt.MaxNLocator(8))
# figure formatting-set title and label
ax[0,0].set_title('Cumulative cases',loc='center',fontsize=24)
ax[0,1].set_title('Cumulative deaths',loc='center',fontsize=24)
ax[0,0].text(-0.05,1.1,"A",transform=ax[0,0].transAxes,
             fontsize=24,fontweight='bold')
ax[0,1].text(-0.05,1.1,"B",transform=ax[0,1].transAxes,
             fontsize=24,fontweight='bold')
# create super-x & ylabel
fig.text(0.08,0.5,'Counts (in millions)',va = 'center',rotation='vertical',
             fontsize=24)
fig.text(0.5,0.05,'Date',va = 'center',rotation='horizontal',
             fontsize=24)
ax[id,0].legend(ll,frameon=False,bbox_to_anchor=(-0.01,-1.05),
                loc='lower left',fontsize=24,ncol=2)

#plt.show(block=False)
fig.savefig('../Plots/Figure3.png',bbox_inches="tight")
#fig.savefig('Figure3.png')
#######################################################

#######################################################
## Table S5-S8: RLA burden: Cumulative cases,hosp,icu, deaths
outputs = ['Cases(R)','Cases(C)',
           'Hosp(R)','Hosp(C)',
           'ICU(R)','ICU(C)',
           'Death(R)','Death(C)']
itrC = [R0,outputs[:2]]
itrH = [R0,outputs[2:4]]
itrI = [R0,outputs[4:6]]
itrD = [R0,outputs[6:]]
clC = pd.MultiIndex.from_product(itrC)
clH = pd.MultiIndex.from_product(itrH)
clI = pd.MultiIndex.from_product(itrI)
clD = pd.MultiIndex.from_product(itrD)

tableS5 = pd.DataFrame(index=names,columns=clC)
tableS6 = pd.DataFrame(index=names,columns=clH)
tableS7 = pd.DataFrame(index=names,columns=clI)
tableS8 = pd.DataFrame(index=names,columns=clD)

for r0 in R0:
    for name in names:
        # read cases in RLA to calculate peak time
        df = pd.read_excel(name+'.xlsx',sheet_name='Cases in RLA',
                           header=[0,1])
        #calculate peak time
        pl = df[r0]['Return to status quo after lockdown'].idxmax()

        # calculate cumulative cases,hospitalization,icu & deaths
        dfC = pd.read_excel(name+'.xlsx',sheet_name='Cumulative cases in RLA',
        header=[0,1])

        dfH = pd.read_excel(name+'.xlsx',sheet_name='Cum. hosp. in RLA',
        header=[0,1])

        dfI = pd.read_excel(name+'.xlsx',sheet_name='Cumulative ICU in RLA',
        header=[0,1])


        dfD = pd.read_excel(name+'.xlsx',sheet_name='Cumulative Deaths in RLA',
                            header=[0,1])
        # populate tables with cum. hosp. & deaths at the peak
        tableS5[r0,'Cases(R)'][name] = np.rint((dfC[r0,'Return to status quo after lockdown'].iloc[pl]))

        tableS6[r0,'Hosp(R)'][name] = np.rint((dfH[r0,'Return to status quo after lockdown'].iloc[pl]))

        tableS7[r0,'ICU(R)'][name] = np.rint((dfI[r0,'Return to status quo after lockdown'].iloc[pl]))

        tableS8[r0,'Death(R)'][name] = np.rint((dfD[r0,'Return to status quo after lockdown'].iloc[pl]))


        tableS5[r0,'Cases(C)'][name] = np.rint((dfC[r0,'Coninued closure of Red light area after lockdown'].iloc[pl]))

        tableS6[r0,'Hosp(C)'][name] = np.rint((dfH[r0,'Coninued closure of Red light area after lockdown'].iloc[pl]))

        tableS7[r0,'ICU(C)'][name] = np.rint((dfI[r0,'Coninued closure of Red light area after lockdown'].iloc[pl]))

        tableS8[r0,'Death(C)'][name] = np.rint((dfD[r0,'Coninued closure of Red light area after lockdown'].iloc[pl]))

tableS5.to_excel('TableS5.xlsx')
tableS6.to_excel('TableS6.xlsx')
tableS7.to_excel('TableS7.xlsx')
tableS8.to_excel('TableS8.xlsx')

########################################################

########################################################
## Figure 4: Burden in RLA as percentage reduction
# get data from table S6-S8
fig3a = pd.DataFrame(index=names,columns=R0)
fig3b = pd.DataFrame(index=names,columns=R0)
fig3c = pd.DataFrame(index=names,columns=R0)

for r0 in R0:
    oa = tableS6[r0]['Hosp(R)']
    na = tableS6[r0]['Hosp(C)']
    pca = (oa-na)/oa
    ob = tableS7[r0]['ICU(R)']
    nb = tableS7[r0]['ICU(C)']
    pcb = (ob-nb)/ob
    oc = tableS8[r0]['Death(R)']
    nc = tableS8[r0]['Death(C)']
    pcc = (oc-nc)/oc
    fig3a[r0] = pca
    fig3b[r0] = pcb
    fig3c[r0] = pcc

# plot figure
fig3a = 100*fig3a.iloc[:,0:3]
fig3b = 100*fig3b.iloc[:,0:3]
fig3c = 100*fig3c.iloc[:,0:3]

fig3a.rename(index={'Delhi':'New Delhi'},inplace=True)
fig3b.rename(index={'Delhi':'New Delhi'},inplace=True)
fig3c.rename(index={'Delhi':'New Delhi'},inplace=True)

plt.close('all')
#my_cols = ['#bdbdbd','#969696','#737373']
#my_cols = ['#d0e1f9','#4d648d','#1e1f26']
my_cols = ['#c9d1c8','#5b7065','#04202c']
#my_cols = ['#8e9b97','#537072','#2c4A52']
fig, ax = plt.subplots(3,1,figsize=(16,12),sharex=True)
# plots
fig3a.plot(kind='bar',ax=ax[0],color=my_cols)
fig3b.plot(kind='bar',ax=ax[1],color=my_cols,legend=False)
fig3c.plot(kind='bar',ax=ax[2],color=my_cols,legend=False,rot=0)

# formatting
tns = ['Reduction in cumulative hospitalizations (%) in RLA at epidemic peak  if they remain closed',
       'Reduction in cumulative ICU admissions (%) in RLA at epidemic peak if they remain closed',
       'Reduction in cumulative deaths (%) in RLA at epidemic peak if they remains closed']
sn = ['A','B','C']
for idx,a in enumerate(ax):
    a.spines['top'].set_visible(False)
    a.spines['right'].set_visible(False)
    a.tick_params('both',labelsize=18)
    a.set_title(tns[idx],loc='center',fontsize=18)
    a.text(-0.04,1.05,sn[idx],transform=a.transAxes,
             fontsize=18,fontweight='bold')

ax[0].legend(['$R_0$=1.75','$R_0$=2','$R_0$=2.25'],
             frameon=False,fontsize=14)
fig.text(0.065,0.5,'Percentage reduction',va = 'center',rotation='vertical',
             fontsize=20)
fig.savefig('../Plots/Figure4.png',bbox_inches="tight")
#fig.savefig('Figure3.png',bbox_inches="tight")
########################################################

########################################################
## Figure 5-> Burden on hospitalizations
plt.close('all')
r0 = 'R0=2'
# read Cases to find peak for India at R0 =2
dd = pd.read_excel('India.xlsx',sheet_name='Cases in RLA',
                       header=[0,1])
pl = dd[r0]['Return to status quo after lockdown'].idxmax()

# Read hospitalization data per day
df = pd.read_excel('India.xlsx',sheet_name='Hospitalization',
                   header=[0,1])
# grab dates for plotting (60 days before peak to 11 days after-for good visualization)
tt = df['R0'][pl-60:pl+11]

fig, ax= plt.subplots(figsize=(16,12))
# get hospitalization data per million for re-opening & closure
data = df[r0].iloc[:,1:]/1000000
# plot both data
ax.plot(tt,data.iloc[pl-60:pl+11,0],'#fc8d59',
        tt,data.iloc[pl-60:pl+11,1],'#2b8cbe',
        linewidth=3)
# figure formatting
ax.spines['top'].set_visible(False)
ax.spines['right'].set_visible(False)
ax.axhline(y=1.9,color='k',linestyle='dashed')
ax.text(tt.iloc[2],1.9,'Current hospital capacity',fontsize=16,
        backgroundcolor= ax.get_facecolor())
ax.axhline(y=5*1.9,color='k',linestyle='dashed') # 5.5 times
ax.text(tt.iloc[2],5*1.9,'5 times current hospital capacity',fontsize=16,
        backgroundcolor=ax.get_facecolor())
ax.axhline(y=10*1.9,color='k',linestyle='dashed') # 9.8 times
ax.text(tt.iloc[2],10*1.9+0.05,'10 times current hospital capacity',
        fontsize=16,backgroundcolor=ax.get_facecolor())
ax.set_xlabel('Date',fontsize=20)
ax.set_ylabel('Hospitalization (in millions)',fontsize=20)
ax.xaxis.set_major_formatter(date_form)
#ax.tick_params(axis='x',which='minor',bottom=False)
ax.tick_params(axis='both',labelsize=18)

ax.legend(ll,frameon=False,bbox_to_anchor=(0.5,1.1),
                loc='upper center',fontsize=18,ncol=2)

#plt.show(block=False)

fig.savefig('../Plots/Figure5.png')
fig.savefig('Figure5.png')
