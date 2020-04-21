close all;
clear all;
%% Initialization to get parameters
% Age-distribution (0-19,20-49,50-64,65-)
Amin=[0 20 50 65];
A=length(Amin);
RLA = {'RLAC1','RLAC2','RLAC3','RLAC4','RLAC5'};

%% Get parameters
% Getting model parameters along with calculating transmission
% parameter (\beta) for India that will be applied to each state
wr = 5;
State = RLA(wr);
% Reproduction number (Change this to assume different R0)
R0E=2;
[beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,delta,mh,mueH,psiH,mc,mueC,psiC,P]=ParameterOutput(Amin,R0E,State,0);
% Note: population parameter (P) we get here is for all India. The
% P vector that has population for each state being considered will
% be constructed.

%% Parameterization and Initialization of state-specific model
load IndiaDemo
names = Pop_Dist.Properties.VariableNames;
States = names(:,2*wr:2*wr+1);
[M,M2,Popt] = DemoIndia(Amin,States(1),0);
popR = [5471.4,2310,4048,16000,6345]';
Pop = [Popt;popR(wr)];


%% Red light areas to use
CP = [0.021605997,0.08710681,0.039846154,...
      0.142222222,0.123698899]; % Contact rates
CGR = [49,60,74,64,82,35]; % Average interaction general pop with RLA
RGC = [49,60,74,64,82,35];
MA = M; MH = M2;

% Incorporate connectivity between states among general contact
% patterns
cpd = CP(wr);
CM = [repelem(1,4,4),cpd*ones(4,1);[0,cpd,cpd,0,1]];
%CM = [repelem(1,4,4),cpd*ones(4,1);[cpd,cpd,cpd,cpd,1]];
M = [M,CGR(wr)*ones(4,1);RGC(wr)*ones(1,5)];
M = CM.*M;
% No connectivity among states for people in isolation
M2 = [M2,zeros(4,1);[0,0,0,0,1]]; % how do we decide household
                                 % probability



noi = [1,0];% Number of infections seeding infection
IC=zeros(11*(A+1),1);        % Initialzing initial conditions
IC(1:A+1)=Pop;             % Susceptible population
IC(2:3:A+1)=IC(2:3:A+1)-noi';    % Seeding infections in age-group 2
IC(A+1+2:3:2*(A+1))=noi';   % Seeding infections in age-group 2


%% Run model
options = odeset('RelTol',10^(-9),'AbsTol',(10^(-9).*ones(size(IC))),...
                 'NonNegative',1:(11*(A+1)));

%% without any lockdown (If no intervention)
tl = 365; % total time to run
[TM0,YM0]=ode15s(@(t,y)MASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                            delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,CM),...
                 [0:tl],IC,options);


%% with lockdown (Current intervention)
% Run initial period without 21 days lockdown
tbl = 20; % time before lockdown
[TM1,YM1]=ode15s(@(t,y)MASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,CM),...
                  [0:tbl],IC,options);

% Run 21 days lockdown
% Get parameters with lockdown
Mx = M2;
M2x = M2;
IC = YM1(end,:);
ttl = 21; % time till lockdown
[TM2,YM2] = ode15s(@(t,y)MASODE(t,y,beta,kA,kM,sigma,tau,Mx,M2x,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,CM),...
                  [tbl:tbl+ttl],IC,options);

% Run after lockdown
IC = YM2(end,:);
tal = 324;

[TM3,YM3] = ode15s(@(t,y)MASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,CM),...
                  [tbl+ttl:tbl+ttl+tal],IC,options);

% Run after lockdown with RLA closure
M(1:end-1,end) = 0;
M(end,1:end-1) = 0;
IC = YM2(end,:);
tal = 324;
[TM4,YM4] = ode15s(@(t,y)MASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,CM),...
                  [tbl+ttl:tbl+ttl+tal],IC,options);

% Joining all results
% Without continuing lockdown in red light area
TM = vertcat(TM1,TM2(2:end),TM3(2:end));
YM = vertcat(YM1,YM2(2:end,:),YM3(2:end,:));

% continuing lockdown in red light area
TML = vertcat(TM1,TM2(2:end),TM4(2:end));
YML = vertcat(YM1,YM2(2:end,:),YM4(2:end,:));


%% Index for dxdt and x to make readability of code easier
S=     [1:A+1];     % Susceptible
E=   (A+1)+[1:A+1]; % Incubation
IA=2*(A+1)+[1:A+1]; % Asymptomatic infections
IH=3*(A+1)+[1:A+1]; % Symptomatic severe infections (not isolated)
IN=4*(A+1)+[1:A+1]; % Symptomatic mild infections (not isolated)
QH=5*(A+1)+[1:A+1]; % Symptomatic severe infections (isolated)
QN=6*(A+1)+[1:A+1]; % Symptomatic mild infections (not isolated)
H= 7*(A+1)+[1:A+1]; % Hospitalization
C= 8*(A+1)+[1:A+1]; % Need ICU
D= 9*(A+1)+[1:A+1]; % Deaths
CC = 10*(A+1)+[1:A+1]; % Cumulative cases due to RLA

S1 = S(1:4); S2 = S(5);
E1 = E(1:4); E2 = E(5);
IA1 = IA(1:4); IA2 = IA(5);
IH1 = IH(1:4); IH2 = IH(5);
IN1 = IN(1:4); IN2 = IN(5);
QH1 = QH(1:4); QH2 = QH(5);
QN1 = QN(1:4); QN2 = QN(5);
H1 = H(1:4); H2 = H(5);
C1 = C(1:4); C2 = C(5);
D1 = D(1:4); D2 = D(5);


%% Plots
fig = figure('position',[300,200,1600,700]);
st = 1; en = 365;
stl = 15; enl = 50;
subplot(2,1,1)
plot(TM0(st:en),sum(YM0(st:en,[IA IH IN QH QN])/1000000,2),'k', ...
     'LineWidth',2.5); hold on;
plot(TM(st:en),sum(YM(st:en,[IA IH IN QH QN])/1000000,2),'b', ...
    'LineWidth',2.5);hold on;
plot(TML(st:en),sum(YML(st:en,[IA IH IN QH QN])/1000000,2),'g', ...
    'LineWidth',2.5);hold on;
box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
title('Infections');
ylabel('Cases(in millions)','Fontsize',16);
legend('No lockdown','lockdown','RLA lockdown');
legend boxoff
subplot(2,1,2)
plot(TM0(stl:enl),sum(YM0(stl:enl,[IA IH IN QH QN]),2),'k','LineWidth',2.5); hold on;
plot(TM(stl:enl),sum(YM(stl:enl,[IA IH IN QH QN]),2),'b', ...
     'LineWidth',2.5);hold on;
plot(TML(stl:enl),sum(YML(stl:enl,[IA IH IN QH QN]),2),'g', ...
     'LineWidth',2.5);hold on;
box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
ylabel('Cases','Fontsize',16);

hold off

%print('Delhi','-dpng')


rang = {'#636363','#fdbb84','#bf5b17','#beaed4','#386cb0'};
%close all;
fig = figure('position',[300,200,1600,700]);
plot(TM(st:en),sum(YM(st:en,[CC]),2),...
     'color',hex2rgb(rang(3)),...
     'LineWidth',2.5);
hold on;
plot(TML(st:en),sum(YML(st:en,[CC]),2),...
     'color',hex2rgb(rang(4)),...
     'LineWidth',2.5);
box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
title('Cases attibutable to Red Light Areas');
ylabel('Cases','Fontsize',16);
lg = legend('No continued closure','Continued closure');
lg.FontSize =16;
lg.Location = 'northwest';
legend boxoff;
hold off;

%print('Lockdown','-dpng')
