WR = [1,2,3,4,5,6]; % Indices for locations
                    % 1:Mumbai, 2:Nagpur,3:Delhi,4:Kolkata,5:Pune,6:India

R0 = [1.75,2,2.25,2.5]; % Different values of R0 for which we want results

% Initializing cells for different strategies (time and solutions)
TM0 = {}; YM0 = {}; TM={}; YM={}; TML={}; YML ={}; Pop={};

% Run simulations for each location at different values of R0.
i = 1;
for wr = WR;
    j = 1;
    for r0 = R0;
        [TM0{i}{j},YM0{i}{j},TM{i}{j},...
         YM{i}{j},TML{i}{j},YML{i}{j},Pop{i}{j}] = ...
            RunSimA(wr,r0);
        j=j+1;
    end
    i=i+1;
end

%% Index of solutions to for easier reading
A = 4; Ss = 2; % A = 4 (no of age-groups considered), Ss = 2 (2
               % populations, Citywide & Red light area)

S=     [1:A*Ss];    % Susceptible
E=   A*Ss+[1:A*Ss]; % Incubation
IA=2*A*Ss+[1:A*Ss]; % Asymptomatic infections
IH=3*A*Ss+[1:A*Ss]; % Symptomatic severe infections (not isolated)
IN=4*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
QH=5*A*Ss+[1:A*Ss]; % Symptomatic severe infections (isolated)
QN=6*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
H= 7*A*Ss+[1:A*Ss]; % Hospitalization
C= 8*A*Ss+[1:A*Ss]; % Need ICU
D= 9*A*Ss+[1:A*Ss]; % Deaths
CC = 10*A*Ss+[1:A*Ss]; % Cumulative cases
ER= 11*A*Ss+[1:A*Ss]; % Incubation
IAR=12*A*Ss+[1:A*Ss]; % Asymptomatic infections
IHR= 13*A*Ss+[1:A*Ss]; % Symptomatic severe infections (not isolated)
INR=14*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
QHR=15*A*Ss+[1:A*Ss]; % Symptomatic severe infections (isolated)
QNR=16*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
HR= 17*A*Ss+[1:A*Ss]; % Hospitalization
CR= 18*A*Ss+[1:A*Ss]; % Need ICU
DR= 19*A*Ss+[1:A*Ss]; % Deaths
CCR=20*A*Ss+[1:A*Ss];% Cumulative number of cases due to Red light area


S1 = S(1:4); S2 = S(5:end);
E1 = E(1:4); E2 = E(5:end);
IA1 = IA(1:4); IA2 = IA(5:end);
IH1 = IH(1:4); IH2 = IH(5:end);
IN1 = IN(1:4); IN2 = IN(5:end);
QH1 = QH(1:4); QH2 = QH(5:end);
QN1 = QN(1:4); QN2 = QN(5:end);
H1 = H(1:4); H2 = H(5:end);
C1 = C(1:4); C2 = C(5:end);
D1 = D(1:4); D2 = D(5:end);



% Calculate delay in peaks under different scenarios
st = 1; en = 365;
stl = 15; enl = 50;

% delay in peaks
Dl = [];
for i = 1:6; % varying over RLAs
    for j = 1:4; %varying over R0
        yM = YM{i}{j};
        yML = YML{i}{j};
        [v0,ix0] = max(sum(yM(st:en,[IA IH IN QH QN]),2));
        [vL,ixL] = max(sum(yML(st:en,[IA IH IN QH QN]),2));
        Dl(i,j) = ixL - ix0;
    end
end


% difference in peaks
Pl = []; %zeros(5,5);
for i = 1:6; % varying over RLAs
    for j = 1:4; % varying over R0
        yM = YM{i}{j};
        yML = YML{i}{j};
        [v0,ix0] = max(sum(yM(st:en,[IA IH IN QH QN]),2));
        [vL,ixL] = max(sum(yML(st:en,[IA IH IN QH QN]),2));
        Pl(i,j) = v0 - vL;
    end
end


% cases averted originating from Red Light Areas
Cs = [];

for i = 1:6; % varying over RLAs
    for j = 1:4; % varying over R0
        yM = YM{i}{j};
        yML = YML{i}{j};
        [v0,ix0] = max(sum(yM(st:en,[CCR]),2));
        [vL,ixL] = max(sum(yML(st:en,[CCR]),2));
        Cs(i,j) = v0 - vL;
    end
end

% deaths averted originating from Red Light Areas
Ds = [];

for i = 1:6; % varying over RLAs
    for j = 1:4; % varying over R0
        yM = YM{i}{j};
        yML = YML{i}{j};
        [v0,ix0] = max(sum(yM(st:en,[DR]),2));
        [vL,ixL] = max(sum(yML(st:en,[DR]),2));
        Ds(i,j) = v0 - vL;
    end
end




%% Save data to read in python
locations = {'Mumbai','Nagpur','Delhi','Kolkata','Pune','India'};
for i = 1:6
    Cases = []; CasesR = []; CasesPC = []; CasesRPC = [];
    CLR = []; DLR = []; CumCases = []; Hosp = []; HospR = [];
    Deaths = []; DeathsR = [];
    for k = 1:4 % varying over R0
        tM0 = TM0{i}{k}; tM = TM{i}{k}; tML = TML{i}{k};
        yM0 = YM0{i}{k}; yM = YM{i}{k}; yML = YML{i}{k};
        PopA = sum(Pop{i}{k});
        PopR = sum(Pop{i}{k}(5:8));
        t = {tM0,tM,tML}; y = {yM0,yM,yML};
        for j = 1:3
            Cases = [Cases,sum(y{j}(st:en,[IA IH IN QH QN]),2)];
            CasesPC = [CasesPC,1000*sum(y{j}(st:en,[IA IH IN QH QN]),2)/ ...
                       PopA];
            CasesR = [CasesR,1000*sum(y{j}(st:en,[IA2 IH2 IN2 QH2 QN2]),2)/PopR];
            CasesRPC = [CasesRPC,1000*sum(y{j}(st:en,[IA2 IH2 IN2 ...
                                QH2 QN2]),2)/PopR];
            CumCases = [CumCases,sum(y{j}(st:en,[CC]),2)];
            Deaths = [Deaths,sum(y{j}(st:en,[D]),2)];
            DeathsR = [DeathsR,sum(y{j}(st:en,[D2]),2)];
            Hosp = [Hosp,sum(y{j}(st:en,[H,C]),2)];
            HospR = [HospR,sum(y{j}(st:en,[H2,C2]),2)];
            CLR = [CLR,sum(y{j}(st:en,[CCR]),2)];
            DLR = [DLR,sum(y{j}(st:en,[DR]),2)];

        end
        % for j = 2:3
        %     CLR = [CLR,sum(y{j}(st:en,[CCR]),2)];
        %     DLR = [DLR,sum(y{j}(st:en,[DR]),2)];
        % end

    end
filename = strcat(locations{i},'.mat');
save(filename,'Cases','CasesPC','CasesR','CasesRPC','CLR','DLR','CumCases','Hosp','HospR','Deaths','DeathsR');
end

% save summary
save('summary.mat','Dl','Pl','Cs','Ds');


%% Plots
locations =  {'Mumbai','Nagpur','Delhi','Kolkata','Pune','India'};
rang= {'#fef0d9','#fdcc8a','#fc8d59','#e34a33','#b30000'};
dm = [1,1,4];
% Incidence Per Capita
for i = 1:6
    tM0 = TM0{i}{3}; tM = TM{i}{3}; tML = TML{i}{3};
    yM0 = YM0{i}{3}; yM = YM{i}{3}; yML = YML{i}{3};
    PopA = sum(Pop{i}{3});
    PopR = sum(Pop{i}{3}(5:8));
    t = {tM0,tM,tML}; y = {yM0,yM,yML};
    colorG = {'k-','b-','g-'};
    colorR = {'ko','bo','go'};
    xpos = -40;
    close all;
    fig = figure('position',[300,200,1400,1200]);%,'visible','off');

    %[hs,ps] = tight_subplot(2,1,[.05 .05],[.1 .1],[.1 .03]);
    %axes(hs(1));
    subplot(2,2,[1,2])
    for j = 1:3
        plot(t{j}(st:en),...
             (1000*sum(y{j}(st:en,[IA IH IN QH QN]),2)/PopA),colorG{j}, ...
             'LineWidth',2);
        hold on;
        plot(t{j}(st:dm(j):en),...
             (1000*sum(y{j}(st:dm(j):en,[IA2 IH2 IN2 QH2 QN2]),2)/PopR),...
             colorR{j}, 'LineWidth',1,'MarkerSize',4);
        hold on;
    end
    box off;
    xlim([0,365]);
    set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
    title('Infections');
    yp = ylabel('Cases per thousand','Fontsize',20);
    pos = get(yp,'Pos');
    xlabel('Days','Fontsize',20);
    %set(yp,'Pos',[-20,pos(2),pos(3)]);
    %set(gca,'XTickLabel',[])
    % lg = legend('No lockdown','No lockdown (RLA)',...
    %             'Lockdown','Lockdown (RLA)',...
    %             'Continued closure of RLA',...
    %             'Continued closure of RLA (RLA)');
    lg = legend('Citywide, No initial lockdown',...
                'RLA, No initial lockdown',...
                'Citywide, Initial lockdown, No continued RLA closure',...
                'RLA, Initial lockdown, No continued RLA closure',...
                'Citywide, Initial lockdown, Continued RLA closure',...
                'RLA, Initial lockdown, Continued RLA closure')
    lg.FontSize = 20;
    % lt = get(lg,'Title');
    % set(lt,'String','Pop, Initial lockdown, Continued RLA closure','FontSize',12);
    legend boxoff
    %axes(hs(2))
    subplot(2,2,3)
    for j = 2:3
        plot(t{j}(st:en),sum(y{j}(st:en,[CCR]),2),...
            colorR{j},'LineWidth',1,'MarkerSize',4);
        hold on;
    end
    box off;
    xlim([0,365]);
    set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
    title('Cases linked to RLA');
    yp = ylabel('Cases','Fontsize',20);
    xlabel('Days','Fontsize',20);
    %pos = get(yp,'Pos');
    %set(yp,'Pos',[xpos,pos(2),pos(3)]);
    lg = legend('No continued closure','Continued closure');
    lg.FontSize =20;
    lg.Location = 'east';
    legend boxoff;
    [ax,h] = suplabel('Days','x');
    set(h,'FontSize',20);
    hold off;

    subplot(2,2,4)
    for j = 2:3
        plot(t{j}(st:en),sum(y{j}(st:en,[DR]),2),...
            colorR{j},'LineWidth',1,'MarkerSize',4);
        hold on;
    end
    box off;
    xlim([0,365]);
    set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
    title('Deaths linked to RLA');
    yp = ylabel('Deaths','Fontsize',20);
    pos = get(yp,'Pos');
    %set(yp,'Pos',[xpos,pos(2),pos(3)]);
    xlabel('Days','Fontsize',20);
    lg = legend('No continued closure','Continued closure');
    lg.FontSize =20;
    lg.Location = 'east';
    legend boxoff;
    [ax,h] = suplabel('Days','x');
    set(h,'FontSize',20);
    hold off;

    filename = locations{i}; %strcat('RLA',int2str(i));
    print(filename,'-dpng');
end

% Plot summary statistics:
titles = {'Delay in peak','Cases averted at peak',...
          'Cases linked to RLA averted','Deaths linked to RLA averted'};
yl = {'Days','Cases','Cases','Deaths'};
%xpos = -0.25;
Smry = {Dl,Pl,Cs,Ds};
close all;
fig = figure('position',[300,200,1400,1600]);%%,'visible','off');
[hs,ps] = tight_subplot(4,1,[.05 .05],[.1 .1],[.07 .01]);
for i = 1:4
    %subplot(3,1,i)
    axes(hs(i));
    colormap(hex2rgb(rang));
    bar(Smry{i}(1:5,:));
    title(titles{i},'FontSize',14);
    yp = ylabel(yl{i},'FontSize',24);
    pos = get(yp,'Pos');
    %set(yp,'Pos',[xpos,pos(2),pos(3)]);
    set(gca,'FontSize',16);
    if i<4
        set(gca,'XTickLabel',[]);
    else
        set(gca,'XTickLabel',{'RLA 1','RLA 2','RLA 3','RLA 4',...
                   'RLA 5','India'});
    end

    if i ==1
        hleg = legend('2','2.25','2.5');
        hleg.FontSize = 18;
        htitle = get(hleg,'Title');
        set(htitle,'String','R_0','FontSize',18);
        legend boxoff;
    end

    % if i == 1
    %     ylim([0,150]);
    % elseif i == 2
    %     ylim([0,3000]);
    % elseif i ==3
    %     ylim([0,10000]);
    % else
    %     ylim([0,300]);
    % end
    box off;
end
[ax,h] = suplabel('Red light areas','x');
set(h,'FontSize',20);

% [ax,h] = suplabel('Delay in peak','y');
% set(h,'FontSize',18);
print('Summary','-dpng');