function [TM0,YM0,TM,YM,TML,YML,Pop] = RunSimA(wr,r0,fit)
close all;
%% Initialization to get parameters
% Age-distribution (0-19,20-49,50-64,65-)
Amin=[0 20 50 65];
A=length(Amin);
RLA = {'Mumbai','Nagpur','Delhi','Kolkata','Pune','India'};
%% Get parameters
State = RLA{wr};
R0E=r0;

[beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,delta,mh,mueH,psiH,mc,mueC,psiC,P]=ParameterOutput(Amin,R0E,State,0);

tm = 1/beta;


%% Parameterization and Initialization of state-specific model
load IndiaDemo
names = Pop_Dist.Properties.VariableNames;
Pop = [];
States = names(:,2*wr:2*wr+1);
for State = States;
    [M,M2,Popt] = DemoIndia(Amin,State,0);
    Pop = [Pop;Popt];
end
MA = M; MH = M2;
Ss = length(States);



CP = [0.021605997,0.08710681,0.039846154,...
      0.142222222,0.123698899,0.014836909]; % Corresponding contact rates

cpd = CP(wr);
CM = [1,cpd;cpd,1];
CM = repelem(CM,A,A);
M = repmat(M,Ss);
M = CM.*M;

M2 = kron(eye(Ss),M2);

% Make initial condition- prevalence based.
prev = fit;
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
q = [0.5,0.5];          %f = 0.5;

[TM2,YM2] = ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,Mx,M2x,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                  [tbl:tbl+ttl],IC,options);

% Run after lockdown
%q = [0.5,0.5];
IC = YM2(end,:);
tal = 325;
[TM3,YM3] = ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                  [tbl+ttl:tbl+ttl+tal],IC,options);

% Run after lockdown with RLA closure
%q = [0.5,0.5];
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


end
