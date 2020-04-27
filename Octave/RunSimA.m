function [TM0,YM0,TM,YM,TML,YML,Pop] = RunSimA(wr,r0)
close all;
%% Initialization to get parameters
% Age-distribution (0-19,20-49,50-64,65-)
Amin=[0 20 50 65];
A=length(Amin);
RLA = {'Mumbai','Nagpur','Delhi','Kolkata','Pune','India'};

%% Get parameters
% Getting model parameters for relevant location and R0
State = RLA{wr};
% Reproduction number (Change this to assume different R0)
R0E=r0;

[beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,delta,mh,mueH,psiH,mc,mueC,psiC,P]=ParameterOutput(Amin,R0E,wr,0);

% We assume that probability of infection for interaction between
% red light area and general population is 1.
tm = 1/beta; % transmission scaling factor for interaction


%% Parameterization and Initialization

% load data on population distribution
load IndiaDemo
Pop = [];
States = [2*wr:2*wr+1];
for State = States;
    [M,M2,Popt] = DemoIndia(Amin,State,0);
    Pop = [Pop;Popt];
end

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
% No connectivity among regions
M2 = kron(eye(Ss),M2);

% Initial condition- prevalence based.
prev = 0.001; % assuming initial prevalence
cG = 0.01*prev*sum(Pop(1:4));
cR = 0.01*prev*sum(Pop(5:8));
noi = [cG,cR];                     % Number of infections seeding infection
IC=zeros(21*A*Ss,1);               % Initialzing initial conditions
IC(1:A*Ss)=Pop;                    % Susceptible population
IC(2:4:A*Ss)=IC(2:4:A*Ss)-noi';    % Seeding infections in
                                   % age-group 2 of both populations
IC(A*Ss+2:4:2*A*Ss)=noi';          % Seeding infections in age-group 2


%% Run model
options = odeset('RelTol',10^(-9),'AbsTol',(10^(-9).*ones(size(IC))),...
                 'NonNegative',1:(21*A*Ss));

%% without any lockdown (If no intervention)
tl = 366; % total time to run

[TM0,YM0]=ode45(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                            delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                 [0:tl],IC,options);


%% with lockdown (Current intervention)
% Run 21 days lockdown

% interventions:
Mx = M2; % setting houshold contact patterns for everyone
M2x = M2;

f = 0.5; % changing the proportion of symptomatic being isolated/quaranteed
         % to home.

% run model:
tbl = 0;
ttl = 40; % time till lockdown

[TM2,YM2] = ode45(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,Mx,M2x,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                  [tbl:tbl+ttl],IC,options);

% Run after lockdown without RLA closure
IC = YM2(end,:);
tal = 326;

[TM3,YM3] = ode45(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                  [tbl+ttl:tbl+ttl+tal],IC,options);

% Run after lockdown with RLA closure
CM = [1,0;0,1]; % ensuring no connectivity between two region with
                % setting off diagonal elements to be zero.
CM = repelem(CM,A,A);
M = repmat(MA,Ss);
M = CM.*M;
IC = YM2(end,:);
tal = 326;
[TM4,YM4] = ode45(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                  [tbl+ttl:tbl+ttl+tal],IC,options);

% Joining all results
% Without continuing lockdown in red light area
TM = vertcat(TM2,TM3(2:end));
YM = vertcat(YM2,YM3(2:end,:));

% continuing lockdown in red light area
TML = vertcat(TM2,TM4(2:end));
YML = vertcat(YM2,YM4(2:end,:));
end
