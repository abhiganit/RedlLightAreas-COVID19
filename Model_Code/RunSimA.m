function [TM0,YM0,TM,YM,TML,YML,Pop] = RunSimA(wr,r0,fit)
%close all;
%wr = 6; r0 = 2.5; fit = 0.0005;
%% Initialization to get parameters
% Age-distribution (0-19,20-49,50-64,65-)
Amin=[0 20 50 65];
A=length(Amin);
RLA = {'Mumbai','Nagpur','Delhi','Kolkata','Pune','India'};
%% Get parameters
State = RLA{wr};
R0E=r0;

[beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,delta,mh,mueH,psiH,mc,mueC,psiC,P]=ParameterOutput(Amin,R0E,wr,0);

% Calculating transmission multiplier to make probability of
% infection during interaction of two population = 1 and increasing
% contact pattern for the interaction.
int_per_visit = [49,60,74,64,82,35];
int_mult = int_per_visit(wr)/mean(mean(M))
tm = int_mult/beta;

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


Ss = length(States);

% Contact rates to connect to populations
CP = [0.021605997,0.08710681,...
      0.039846154,0.142222222,...
      0.123698899,0.014836909]; % Corresponding contact rates

cpd = CP(wr);
% Create connection matrix
CM = [1,cpd;cpd,1];
% Scale up connection matrix to match age-distribution
CM = repelem(CM,A,A);
% Apply connection matrix to contact pattern matrix
M = repmat(M,Ss);
M = CM.*M;

% Contact pattern matrix for quarantine/isolation
M2 = kron(eye(Ss),M2);

% Make initial condition- prevalence based.
prev = fit;
cG = 0.01*prev*sum(Pop(1:4));
cR = 0.01*prev*sum(Pop(5:8));
noi =[cG,cR];                      % Number of infections seeding infection
IC=zeros(15*A*Ss,1);               % Initialzing initial conditions
IC(1:A*Ss)=Pop;                    % Susceptible population
IC(2:4:A*Ss)=IC(2:4:A*Ss)-noi';    % Seeding infections in age-group 2
IC(A*Ss+2:4:2*A*Ss)= noi';         % Seeding infections in age-group 2

%% Run model
options = odeset('RelTol',10^(-9),'AbsTol',(10^(-9).*ones(size(IC))),...
                 'NonNegative',1:(15*A*Ss));

%% without any lockdown (If no intervention)
tl = 365; % total time to run

[TM0,YM0]=ode45(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                            delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                 [0:tl],IC,options);


%% with lockdown (Current intervention)
% % Run 40 days lockdown
% Get parameters for lockdown
Mx = M2;  % contact patterns set to household matrix during
          % lockdown, no connection between populations
M2x = M2; % household contact patterns for quarantined populations
tbl = 0;  % initial point
ttl = 40; % time till lockdown
q = 0.5;  % proportion of cases being quarantined set to 50%

[TM2,YM2] = ode45(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,Mx,M2x,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                  [tbl:tbl+ttl],IC,options);

% Run after lockdown without RLA closure
% All parameters go back to status quo,except proportion being quarantined
IC = YM2(end,:);
tal = 325;
[TM3,YM3] = ode45(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                  [tbl+ttl:tbl+ttl+tal],IC,options);

% Run after lockdown with RLA closure
% Set contact between two population to be zero
CM = [1,0;0,1];
CM = repelem(CM,A,A); % scale it up to match age-distribution

M = repmat(MA,Ss); % overall contact pattern scaled to match age-dist.
M = CM.*M; % apply connection matrix to contact patterns

IC = YM2(end,:);
tal = 325;
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
