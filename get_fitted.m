function out = get_fitted(betaF)
wr =1;
close all;
Amin=[0 20 50 65];
A=length(Amin);
RLA = {'Mumbai','Nagpur','Delhi','Kolkata','Pune','India'};
State = RLA{wr};
R0E=2;
[beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,delta,mh,mueH,psiH,mc,mueC,psiC,P]=ParameterOutput(Amin,R0E,State,0);

beta = betaF;
tm = 1/beta;

load IndiaDemo
names = Pop_Dist.Properties.VariableNames;
Pop = [];
States = names(:,2*wr:2*wr+1);
for State = States;
    [M,M2,Popt] = DemoIndia(Amin,State,0);
    Pop = [Pop;Popt];
end
%Pop(5:8) = Pop(5:8);
MA = M; MH = M2;
% Number of states being cosnidered
Ss = length(States);

% Incorporate connectivity between states among general contact
% patterns
CP = [0.021605997,0.08710681,0.039846154,...
      0.142222222,0.123698899,0.014836909]; % Corresponding contact rates

cpd = CP(wr);
CM = [1,cpd;cpd,1];
CM = repelem(CM,A,A);
M = repmat(M,Ss);
M = CM.*M;
% No connectivity among regions for people in isolation
M2 = kron(eye(Ss),M2);



% Make initial condition- prevalence based.
prev = 0.001;
cG = 0.01*prev*sum(Pop(1:4));
cR = 0.01*prev*sum(Pop(5:8));
noi = [cG,cR];                       % Number of infections seeding infection
IC=zeros(13*A*Ss,1);               % Initialzing initial conditions
IC(1:A*Ss)=Pop;                    % Susceptible population
IC(2:4:A*Ss)=IC(2:4:A*Ss)-noi';    % Seeding infections in age-group 2
IC(A*Ss+2:4:2*A*Ss)=noi';          % Seeding infections in age-group 2


%% Run model
options = odeset('RelTol',10^(-9),'AbsTol',(10^(-9).*ones(size(IC))),...
                 'NonNegative',1:(13*A*Ss));

%% without any lockdown (If no intervention)
tl = 365; % total time to run
[TM0,YM0]=ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                            delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                 [0:tl],IC,options);

%% with lockdown (Current intervention)
% Run 21 days lockdown
% Get parameters with lockdown
Mx = M2;
M2x = M2;
%IC = YM1(end,:);
tbl = 0;
ttl = 40; % time till lockdown
f = 0.5;
tau = 1;
%q = 0.5;
[TM2,YM2] = ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,Mx,M2x,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                  [tbl:tbl+ttl],IC,options);


% Run after lockdown
IC = YM2(end,:);
tal = 325;

[TM3,YM3] = ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                  [tbl+ttl:tbl+ttl+tal],IC,options);

% Run after lockdown with RLA closure
CM = [1,0;0,1]; %eye(Ss);
CM = repelem(CM,A,A);
M = repmat(MA,Ss);
M = CM.*M;

IC = YM2(end,:);
tal = 325;
[TM4,YM4] = ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                  [tbl+ttl:tbl+ttl+tal],IC,options);

% Joining all results
% Without continuing lockdown in red light area
% TM = vertcat(TM1,TM2(2:end),TM3(2:end));
% YM = vertcat(YM1,YM2(2:end,:),YM3(2:end,:));
TM = vertcat(TM2,TM3(2:end));
YM = vertcat(YM2,YM3(2:end,:));

% continuing lockdown in red light area
% TML = vertcat(TM1,TM2(2:end),TM4(2:end));
% YML = vertcat(YM1,YM2(2:end,:),YM4(2:end,:));
TML = vertcat(TM2,TM4(2:end));
YML = vertcat(YM2,YM4(2:end,:));


%% Index for dxdt and x to make readability of code easier
A = 4; Ss = 2;
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
CH= 11*A*Ss+[1:A*Ss]; % Incubation
CI=12*A*Ss+[1:A*Ss]; % Asymptomatic infections


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
CC1 = CC(1:4); CC2=CC(5:end);
CH1 = CH(1:4); CH2=CH(5:end);
CI1 = CI(1:4); CI2=CI(5:end);




ym = sum(YM2(:,[CC]),2);
ym = ym([30,31,32,33,34,36]);

out = ym;
end
