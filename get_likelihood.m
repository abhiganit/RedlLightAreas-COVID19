function [out] = get_likelihood(ip,r0,wr)
close all;
%% Initialization to get parameters
Amin=[0 20 50 65]; % Age-distribution (0-19,20-49,50-64,65-)
A=length(Amin);
RLA = {'Mumbai','Nagpur','Delhi','Kolkata','Pune','India'};

%% Get parameters
State = RLA{wr};
R0E=r0;
[beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,delta,mh,mueH,psiH,mc,mueC,psiC,P]=ParameterOutput(Amin,R0E,State,0);

int_per_visit = [49,60,74,64,82,35];
int_mult = int_per_visit(wr)/mean(mean(M));
wt = (1+5*beta)/6;
tm =  int_mult*wt/beta;


%% Parameterization and Initialization of  model
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

% Daily interaction between clients and sex-workers
CP= [0.0004409387095,0.001451780159,0.0005384615385,...
    0.002222222222,0.001508523156,0.0004239116965];


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
prev = ip;
cG = 0.01*prev*sum(Pop(1:4));
cR = 0.01*prev*sum(Pop(5:8));
noi = [cG,cR];                     % Number of infections seeding infection
IC=zeros(15*A*Ss,1);               % Initialzing initial conditions
IC(1:A*Ss)=Pop;                    % Susceptible population
IC(2:4:A*Ss)=IC(2:4:A*Ss)-noi';    % Seeding infections in age-group 2
IC(A*Ss+2:4:2*A*Ss)=noi';          % Seeding infections in age-group 2


%% Run model
options = odeset('RelTol',10^(-9),'AbsTol',(10^(-9).*ones(size(IC))),...
                 'NonNegative',1:(15*A*Ss));



%% with lockdown (Current intervention)

% % Run 40 days lockdown
% Get parameters for lockdown
Mx = M2;  % contact patterns set to household matrix during
          % lockdown, no connection between populations
M2x = M2; % household contact patterns for quarantined populations
tbl = 0;  % initial point
ttl = 40; % time till lockdown
q = 0.5;  % proportion of cases being quarantined set to 50%

[TM2,YM2] = ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,Mx,M2x,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                  [tbl:tbl+ttl],IC,options);




%% Index for dxdt and x to make readability of code easier
A = 4; Ss = 2;
S=     [1:A*Ss];    % Susceptible
E=   A*Ss+[1:A*Ss]; % Incubation
EI=2*A*Ss+[1:A*Ss]; % Presymptomatic infectious
IA=3*A*Ss+[1:A*Ss]; % Asymptomatic infections
IH=4*A*Ss+[1:A*Ss]; % Symptomatic severe infections (not isolated)
IN=5*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
QH=6*A*Ss+[1:A*Ss]; % Symptomatic severe infections (isolated)
QN=7*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
H= 8*A*Ss+[1:A*Ss]; % Hospitalization
C= 9*A*Ss+[1:A*Ss]; % Need ICU
D= 10*A*Ss+[1:A*Ss];% Deaths
CC=11*A*Ss+[1:A*Ss];% Cumulative cases
CH=12*A*Ss+[1:A*Ss];% Cumulative hospitalization
CI=13*A*Ss+[1:A*Ss];% Cumulative ICU admissions
CF=14*A*Ss+[1:A*Ss];% Cumulative numbers for model fit



% calculate least-square error
load observed_data
yo = df(:,wr+1);
ym = sum(YM2(:,[CF]),2);
ym = ym(df(:,1));

out = sum((yo - ym).^2); % return error

end
