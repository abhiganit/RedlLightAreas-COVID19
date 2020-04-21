close all;
%% Initialization to get parameters
% Age-distribution (0-19,20-49,50-64,65-)
Amin=[0 20 50 65];
A=length(Amin);
% Reproduction number (Change this to assume different R0)
R0E=2;
% State to run
State = 'RAJASTHAN';

%% Set up initial conditions
% Get parameters
[beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,delta,mh,mueH,psiH,mc,mueC,psiC,P]=ParameterOutput(Amin,R0E,State,0);
beta = 0.0426;
noi = 5;              % Number of infections seeding infection
IC=zeros(10*A,1);     % Initialzing initial conditions
IC(1:A)=P;            % Susceptible population
IC(2)=IC(2)-noi;      % Seeding infections in age-group 2
IC(A+2)=noi;          % Seeding infections in age-group 2


%% Run model
options = odeset('RelTol',10^(-9),'AbsTol',(10^(-9).*ones(size(IC))),...
                 'NonNegative',1:(10*A));

%% without any lockdown (If no intervention)
tl = 700; % total time to run
[TM0,YM0]=ode45(@(t,y)SODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                            delta,mh,mueH,psiH,mc,mueC,psiC,P,A),...
                 [0:tl],IC,options);


%% with lockdown (Current intervention)
% Run initial period without 21 days lockdown
tbl = 20; % time before lockdown
[TM1,YM1]=ode45(@(t,y)SODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,P,A),...
                  [0:tbl],IC,options);

% Run 21 days lockdown
% Get parameters with lockdown
[Mx,M2x,Px] = DemoIndia(Amin,State,1);
IC = YM1(end,:);
ttl = 21; % time till lockdown
[TM2,YM2] = ode45(@(t,y)SODE(t,y,beta,kA,kM,sigma,tau,Mx,M2x,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,P,A),...
                  [tbl:tbl+ttl],IC,options);

% Run after lockdown
IC = YM2(end,:);
tal = 659;
[TM3,YM3] = ode45(@(t,y)SODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,P,A),...
                  [tbl+ttl:tbl+ttl+tal],IC,options);
% Joining all results
TM = vertcat(TM1,TM2(2:end),TM3(2:end));
YM = vertcat(YM1,YM2(2:end,:),YM3(2:end,:));



%% Hospital beds/ICUS etc
% How many beds are available?
%BedsR=round(round(sum(P)*2.2/1000)*0.06);
% % Index for dxdt and x to make readability of code easier
S=     [1:A]; % Susceptible
E=   A+[1:A]; % Incubation
IA=2*A+[1:A]; % Asymptomatic infections
IH=3*A+[1:A]; % Symptomatic severe infections (not isolated)
IN=4*A+[1:A]; % Symptomatic mild infections (not isolated)
QH=5*A+[1:A]; % Symptomatic severe infections (isolated)
QN=6*A+[1:A]; % Symptomatic mild infections (not isolated)
H= 7*A+[1:A]; % Hospitalization
C= 8*A+[1:A]; % Need ICU
D= 9*A+[1:A]; % Deaths

%% Plots
fig = figure('position',[300,200,1600,700])
st = 1; en = 365;
stl = 15; enl = 50;
subplot(2,3,1)
plot(TM0(st:en),sum(YM0(st:en,[IA IH IN QH QN])/1000000,2),'k', ...
     'LineWidth',2.5); hold on;
plot(TM(st:en),sum(YM(st:en,[IA IH IN QH QN])/1000000,2),'r', ...
     'LineWidth',2.5);hold on;
box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
title('Infections');
ylabel('Cases(in millions)','Fontsize',16);
subplot(2,3,2)
plot(TM0(st:en),sum(YM0(st:en,[IH QH])/1000000,2),'k','LineWidth',2.5); hold on;
plot(TM(st:en),sum(YM(st:en,[IH QH])/1000000,2),'r', ...
     'LineWidth',2.5);hold on;
box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
title('Need Hospitalization');

subplot(2,3,3)
plot(TM0(st:en),sum(YM0(st:en,[D])/1000000,2),'k','LineWidth',2.5); hold on;
plot(TM(st:en),sum(YM(st:en,[D])/1000000,2),'r', ...
     'LineWidth',2.5);hold on;
title('Deaths');
box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);

subplot(2,3,4)
plot(TM0(stl:enl),sum(YM0(stl:enl,[IA IH IN QH QN]),2),'k','LineWidth',2.5); hold on;
plot(TM(stl:enl),sum(YM(stl:enl,[IA IH IN QH QN]),2),'r', ...
     'LineWidth',2.5);hold on;

box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
ylabel('Cases','Fontsize',16);
subplot(2,3,5)
plot(TM0(stl:enl),sum(YM0(stl:enl,[IH QH]),2),'k','LineWidth',2.5); hold on;
plot(TM(stl:enl),sum(YM(stl:enl,[IH QH]),2),'b', 'LineWidth',2.5);hold on;

box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);

subplot(2,3,6)
plot(TM0(stl:enl),sum(YM0(stl:enl,[D]),2),'k','LineWidth',2.5); hold on;
plot(TM(stl:enl),sum(YM(stl:enl,[D]),2),'c', ...
     'LineWidth',2.5);hold on;

box off;
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);

[ax,h] = suplabel('Days','x');
set(h,'FontSize',18);



hold off


print(State,'-dpng')
