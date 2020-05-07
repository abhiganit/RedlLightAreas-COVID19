WR = [1,2,3,4,5,6]; % which Red Light Area
R0 = [1.75,2,2.25,2.5]; % Different values of R0
load Fitting

TM0 = {}; YM0 = {}; TM={}; YM={}; TML={}; YML ={}; Pop={};
i = 1;
for wr = WR;
    j = 1;
    for r0 = R0;
        [TM0{i}{j},YM0{i}{j},TM{i}{j},...
         YM{i}{j},TML{i}{j},YML{i}{j},Pop{i}{j}] = ...
            RunSimA(wr,r0,fits(i,j));
        j=j+1;
    end
    i=i+1;
end

%% Index for dxdt and x to make readability of code easier
A = 4; Ss = 2;

S=     [1:A*Ss]; % Susceptible
E=   A*Ss+[1:A*Ss]; % Incubation
EI=2*A*Ss+[1:A*Ss]; % Incubation
IA=3*A*Ss+[1:A*Ss]; % Asymptomatic infections
IH=4*A*Ss+[1:A*Ss]; % Symptomatic severe infections (not isolated)
IN=5*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
QH=6*A*Ss+[1:A*Ss]; % Symptomatic severe infections (isolated)
QN=7*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
H= 8*A*Ss+[1:A*Ss]; % Hospitalization
C= 9*A*Ss+[1:A*Ss]; % Need ICU
D= 10*A*Ss+[1:A*Ss]; % Deaths
CC=11*A*Ss+[1:A*Ss];% Cumulative cases
CH=12*A*Ss+[1:A*Ss];
CI=13*A*Ss+[1:A*Ss];
CF=14*A*Ss+[1:A*Ss];


S1 = S(1:4); S2 = S(5:end);
E1 = E(1:4); E2 = E(5:end);
EI1 = EI(1:4); EI2 = EI(5:end);
IA1 = IA(1:4); IA2 = IA(5:end);
IH1 = IH(1:4); IH2 = IH(5:end);
IN1 = IN(1:4); IN2 = IN(5:end);
QH1 = QH(1:4); QH2 = QH(5:end);
QN1 = QN(1:4); QN2 = QN(5:end);
H1 = H(1:4); H2 = H(5:end);
C1 = C(1:4); C2 = C(5:end);
D1 = D(1:4); D2 = D(5:end);
CC1 = CC(1:4); CC2=CC(5:end);
CH1 = CH(1:4); CH2=CH(5:end);
CI1 = CI(1:4); CI2=CI(5:end);



%% Plots (Have now written code to plot them in Python)
locations =  {'Mumbai','Nagpur','Delhi','Kolkata','Pune','India'};
rang= {'#fef0d9','#fdcc8a','#fc8d59','#e34a33','#b30000'};
st = 1; en = 365;
dm = [1,1,4];
% Incidence Per Capita
ri = 1;
for i = 1:6
    tM0 = TM0{i}{ri}; tM = TM{i}{ri}; tML = TML{i}{ri};
    yM0 = YM0{i}{ri}; yM = YM{i}{ri}; yML = YML{i}{ri};
    PopA = sum(Pop{i}{3});
    PopR = sum(Pop{i}{3}(5:8));
    t = {tM0,tM,tML}; y = {yM0,yM,yML};
    colorG = {'k-','b-','g-'};
    colorR = {'ko','bo','go'};
    xpos = -40;
    %    close all;
    fig = figure('position',[300,200,1400,1200]);%,'visible','off');
    subplot(2,1,1)
    for j = 1:3
        plot(t{j}(st:en),...
             (sum(y{j}(st:en,[IA IH IN QH QN]),2)),colorG{j}, ...
             'LineWidth',2);
        hold on;
    end
    subplot(2,1,2)
    for j = 1:3
        plot(t{j}(st:dm(j):en),...
             (sum(y{j}(st:dm(j):en,[IA2 IH2 IN2 QH2 QN2]),2)),...
             colorR{j}, 'LineWidth',1,'MarkerSize',4);
        hold on;
    end
    box off;
    xlim([0,365]);
    set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
    title('Infections');
    yp = ylabel('Cases','Fontsize',20);
    pos = get(yp,'Pos');
    xlabel('Days','Fontsize',20);
    filename = locations{i}; %strcat('RLA',int2str(i));
    print(filename,'-dpng');
end



st = 1; en = 366;
stl = 15; enl = 50;

%% Delay in peak & difference in peak
% Impact of lockdown
Dcl = []; Pcl = []; Phl = []; Pil = []; Pdl = [];
% Further impact of continued rla closure
Dclr = []; Pclr = []; Phlr = []; Pilr = []; Pdlr = [];

for i = 1:6; % varying over RLAs
    for j = 1:4; %varying over R0
        yM0 = YM0{i}{j};
        yM = YM{i}{j};
        yML = YML{i}{j};
        [v0,ix0] = max(sum(yM0(st:en,[IA IH IN QH QN]),2));
        [vL,ixL] = max(sum(yM(st:en,[IA IH IN QH QN]),2));
        [vR,ixR] = max(sum(yML(st:en,[IA IH IN QH QN]),2));

        % Hospitalization
        h0 = max(sum(yM0(st+1:en,[H,C]),2));
        hl = max(sum(yM(st+1:en,[H,C]),2));
        hr = max(sum(yML(st+1:en,[H,C]),2));
        % ICU
        c0 = max(sum(yM0(st+1:en,[C]),2));
        cl = max(sum(yM(st+1:en,[C]),2));
        cr = max(sum(yML(st+1:en,[C]),2));
        % Deaths
        d0 = max(diff(sum(yM0(st:en,[D]),2)));
        dl = max(diff(sum(yM(st:en,[D]),2)));
        dr = max(diff(sum(yML(st:en,[D]),2)));

        % save
        Dcl(i,j) = ixL - ix0; % delay in peak due to lockdown
        Dclr(i,j) = ixR - ixL;% further delay in peak due to rla closure
        Pcl(i,j) = v0 - vL;
        Pclr(i,j) = vL - vR;
        Phl(i,j) = h0-hl;
        Phlr(i,j) = hl-hr;
        Pil(i,j) = c0-cl;
        Pilr(i,j)= cl-cr;
        Pdl(i,j) = d0-dl;
        Pdlr(i,j) = dl-dr;
    end
end

%% Impact in terms of cumulative numbers
%
Ccl = []; Cclr = [];
Chl = []; Chlr = [];
Cil = []; Cilr = [];
Cdl = []; Cdlr = [];

Cla ={}; Clra ={}; Hla={}; Hlra={};
Ila ={}; Ilra={}; Dla={}; Dlra={};

% June 1: 69 days, July 1: 99 Aug 1:130, Sept 1: 161, Oct 1: 191 Nov 1:222
% Dec 1: 252 % Dec 31: 282
ct = 69;
for i = 1:6; % varying over RLAs
    for j = 1:4; % varying over R0
        yM0 = YM0{i}{j};
        yM = YM{i}{j};
        yML = YML{i}{j};
        cc0 = (sum(yM0(st+1:en,[CC]),2));
        ccl = (sum(yM(st+1:en,[CC]),2));
        ccr = (sum(yML(st+1:en,[CC]),2));
        ch0 = (sum(yM0(st+1:en,[CH,CI]),2));
        chl = (sum(yM(st+1:en,[CH,CI]),2));
        chr = (sum(yML(st+1:en,[CH,CI]),2));
        ci0 = (sum(yM0(st+1:en,[CI]),2));
        cil = (sum(yM(st+1:en,[CI]),2));
        cir = (sum(yML(st+1:en,[CI]),2));
        cd0 = (sum(yM0(st+1:en,[D]),2));
        cdl = (sum(yM(st+1:en,[D]),2));
        cdr = (sum(yML(st+1:en,[D]),2));
        Ccl(i,j) = cc0(ct) - ccl(ct); %max(cc0) - max(ccl);
        Cclr(i,j) = ccl(ct) - ccr(ct); %max(ccl) - max(ccr);
        Chl(i,j) = ch0(ct) - chl(ct);
        Chlr(i,j) = chl(ct)-chr(ct);
        Cil(i,j) = ci0(ct) - cil(ct);
        Cilr(i,j) = cil(ct)-cir(ct);
        Cdl(i,j) = cd0(ct) - cdl(ct);
        Cdlr(i,j) = cdl(ct) -cdr(ct);
        Cla{i}{j} = cc0-ccl;
        Clra{i}{j} = ccl-ccr;
        Hla{i}{j} = ch0-chl;
        Hlra{i}{j} = chl-chr;
        Ila{i}{j} = ci0 - cil;
        Ilra{i}{j} = cil-cir;
        Dla{i}{j} = cd0 - cdl;
        Dlra{i}{j} = cdl - cdr;
    end
end


save('summary.mat','Dcl','Pcl','Phl','Pil','Pdl','Dclr','Pclr',...
     'Phlr','Pilr','Pdlr','Ccl','Cclr','Chl','Chlr','Cil','Cilr',...
     'Cdl','Cdlr','Cla','Clra','Hla','Hlra','Ila','Ilra','Dla',...
     'Dlra')


col_header = {'R0=1.75','R0=2','R0=2.25','R0=2.5'};
row_header = locations;
xlswrite('summary.xlsx',Dcl,'Sheet1','B2')
xlswrite('summary.xlsx',col_header,'Sheet1','B1')
xlswrite('summary.xlsx',row_header,'Sheet1','A2')


% difference in cumulative numbers:






%% Save data to read in python
st = 1;
en = 366;
locations = {'Mumbai','Nagpur','Delhi','Kolkata','Pune','India'};
for i = 1:6
    Cases = []; CasesR = []; Hosp = []; HospR = [];
    ICU = []; ICUR = []; Deaths = []; DeathsR = [];
    CumCases = []; CumHosp = []; CumICU = []; CumDeaths = [];
    CumCasesR = []; CumHospR = []; CumICUR = []; CumDeathsR = [];
    for k = 1:4 % varying over R0
        tM0 = TM0{i}{k}; tM = TM{i}{k}; tML = TML{i}{k};
        yM0 = YM0{i}{k}; yM = YM{i}{k}; yML = YML{i}{k};
        PopA = sum(Pop{i}{k});
        PopR = sum(Pop{i}{k}(5:8));
        t = {tM0,tM,tML}; y = {yM0,yM,yML};
        for j = 1:3
            Cases = [Cases,sum(y{j}(st+1:en,[IA IH IN QH QN]),2)];
            CasesR = [CasesR,sum(y{j}(st+1:en,[IA2 IH2 IN2 QH2 QN2]),2)];

            CumCases = [CumCases,sum(y{j}(st+1:en,[CC]),2)];
            CumCasesR = [CumCasesR,sum(y{j}(st+1:en,[CC2]),2)];

            Deaths = [Deaths,diff(sum(y{j}(st:en,[D]),2))];
            DeathsR = [DeathsR,diff(sum(y{j}(st:en,[D2]),2))];

            CumDeaths = [CumDeaths,sum(y{j}(st+1:en,[D]),2)];
            CumDeathsR = [CumDeathsR,sum(y{j}(st+1:en,[D2]),2)];

            Hosp = [Hosp,sum(y{j}(st+1:en,[H,C]),2)];
            HospR = [HospR,sum(y{j}(st+1:en,[H2,C2]),2)];

            CumHosp = [CumHosp,sum(y{j}(st+1:en,[CH,CI]),2)];
            CumHospR = [CumHospR,sum(y{j}(st+1:en,[CH2,CI2]),2)];

            ICU = [ICU,sum(y{j}(st+1:en,[C]),2)];
            ICUR = [ICUR,sum(y{j}(st+1:en,[C2]),2)];

            CumICU = [CumICU,sum(y{j}(st+1:en,[CI]),2)];
            CumICUR = [CumICUR,sum(y{j}(st+1:en,[CI2]),2)];

        end

    end
filename = strcat(locations{i},'.mat');
save(filename,'Cases','CasesR','CumCases','CumCasesR','Deaths', ...
     'DeathsR','CumDeaths','CumDeathsR','Hosp','HospR','CumHosp',...
     'CumHospR','ICU','ICUR','CumICU','CumICUR','PopA','PopR');
end



%%%

% % Plot summary statistics:
% titles = {'Delay in peak','Cases averted at peak',...
%           'Cases linked to RLA averted','Deaths linked to RLA averted'};
% yl = {'Days','Cases','Cases','Deaths'};
% %xpos = -0.25;
% Smry = {Dl,Pl,Cs,Ds};
% close all;
% fig = figure('position',[300,200,1400,1600]);%%,'visible','off');
% [hs,ps] = tight_subplot(4,1,[.05 .05],[.1 .1],[.07 .01]);
% for i = 1:4
%     %subplot(3,1,i)
%     axes(hs(i));
%     colormap(hex2rgb(rang));
%     bar(Smry{i}(1:5,:));
%     title(titles{i},'FontSize',14);
%     yp = ylabel(yl{i},'FontSize',24);
%     pos = get(yp,'Pos');
%     %set(yp,'Pos',[xpos,pos(2),pos(3)]);
%     set(gca,'FontSize',16);
%     if i<4
%         set(gca,'XTickLabel',[]);
%     else
%         set(gca,'XTickLabel',{'RLA 1','RLA 2','RLA 3','RLA 4',...
%                    'RLA 5','India'});
%     end

%     if i ==1
%         hleg = legend('2','2.25','2.5');
%         hleg.FontSize = 18;
%         htitle = get(hleg,'Title');
%         set(htitle,'String','R_0','FontSize',18);
%         legend boxoff;
%     end

%     % if i == 1
%     %     ylim([0,150]);
%     % elseif i == 2
%     %     ylim([0,3000]);
%     % elseif i ==3
%     %     ylim([0,10000]);
%     % else
%     %     ylim([0,300]);
%     % end
%     box off;
% end
% [ax,h] = suplabel('Red light areas','x');
% set(h,'FontSize',20);

% % [ax,h] = suplabel('Delay in peak','y');
% % set(h,'FontSize',18);
% print('Summary','-dpng');