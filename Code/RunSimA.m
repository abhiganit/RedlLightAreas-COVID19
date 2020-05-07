function [TM0,YM0,TM,YM,TML,YML,Pop] = RunSimA(wr,r0,fit)
%close all;
%wr = 1; r0 = 2.5; fit = 0.0066;
%% Initialization to get parameters
% Age-distribution (0-19,20-49,50-64,65-)
Amin=[0 20 50 65];
A=length(Amin);
RLA = {'Mumbai','Nagpur','Delhi','Kolkata','Pune','India'};
%% Get parameters
State = RLA{wr};
R0E=r0;

[beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,delta,mh,mueH,psiH,mc,mueC,psiC,P]=ParameterOutput(Amin,R0E,State,0);

int_per_visit = [49,60,74,64,82,35];
int_mult = int_per_visit(wr)/mean(mean(M))
tm = int_mult/beta;


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
noi =[cG,cR];                       % Number of infections seeding infection
IC=zeros(15*A*Ss,1);               % Initialzing initial conditions
IC(1:A*Ss)=Pop;                    % Susceptible population
IC(2:4:A*Ss)=IC(2:4:A*Ss)-noi';    % Seeding infections in age-group 2
IC(A*Ss+2:4:2*A*Ss)= noi';         % Seeding infections in age-group 2
%% Run model
options = odeset('RelTol',10^(-9),'AbsTol',(10^(-9).*ones(size(IC))),...
                 'NonNegative',1:(15*A*Ss));

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
tbl = 0;
ttl = 40; % time till lockdown
q = 0.5;

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
%M = blkdiag(MA,MH);
M = repmat(MA,Ss);
M = CM.*M;

IC = YM2(end,:);
tal = 325;
[TM4,YM4] = ode15s(@(t,y)ASODE(t,y,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,...
                             delta,mh,mueH,psiH,mc,mueC,psiC,Pop,A,Ss,CM,tm),...
                  [tbl+ttl:tbl+ttl+tal],IC,options);

% Joining all results
% Without continuing lockdown in red light area
TM = vertcat(TM2,TM3(2:end));
YM = vertcat(YM2,YM3(2:end,:));

% continuing lockdown in red light area
TML = vertcat(TM2,TM4(2:end));
YML = vertcat(YM2,YM4(2:end,:));



%%% Delete later
% % % % %% Index for dxdt and x to make readability of code easier
% A = 4; Ss = 2;

% S=     [1:A*Ss]; % Susceptible
% E=   A*Ss+[1:A*Ss]; % Incubation
% EI=2*A*Ss+[1:A*Ss]; % Incubation
% IA=3*A*Ss+[1:A*Ss]; % Asymptomatic infections
% IH=4*A*Ss+[1:A*Ss]; % Symptomatic severe infections (not isolated)
% IN=5*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
% QH=6*A*Ss+[1:A*Ss]; % Symptomatic severe infections (isolated)
% QN=7*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
% H= 8*A*Ss+[1:A*Ss]; % Hospitalization
% C= 9*A*Ss+[1:A*Ss]; % Need ICU
% D= 10*A*Ss+[1:A*Ss]; % Deaths
% CC=11*A*Ss+[1:A*Ss];% Cumulative cases
% CH=12*A*Ss+[1:A*Ss];
% CI=13*A*Ss+[1:A*Ss];
% CF=14*A*Ss+[1:A*Ss];


% S1 = S(1:4); S2 = S(5:end);
% E1 = E(1:4); E2 = E(5:end);
% EI1 = EI(1:4); EI2 = EI(5:end);
% IA1 = IA(1:4); IA2 = IA(5:end);
% IH1 = IH(1:4); IH2 = IH(5:end);
% IN1 = IN(1:4); IN2 = IN(5:end);
% QH1 = QH(1:4); QH2 = QH(5:end);
% QN1 = QN(1:4); QN2 = QN(5:end);
% H1 = H(1:4); H2 = H(5:end);
% C1 = C(1:4); C2 = C(5:end);
% D1 = D(1:4); D2 = D(5:end);
% CC1 = CC(1:4); CC2=CC(5:end);
% CH1 = CH(1:4); CH2=CH(5:end);
% CI1 = CI(1:4); CI2=CI(5:end);


% % % % % % % % % Asymptomatic
% plot(TM0,sum(YM0(:,[IA]),2),'b','Linewidth',2); hold on;
% plot(TM,sum(YM(:,[IA]),2),'c','Linewidth',2); hold on;
% plot(TML,sum(YML(:,[IA]),2),'r','Linewidth',2); hold on;
% % % % % % % Not isolated
% plot(TM0,sum(YM0(:,[IH,IN]),2),'k','Linewidth',2); hold on;
% plot(TM,sum(YM(:,[IH,IN]),2),'g','Linewidth',2); hold on;
% plot(TML,sum(YML(:,[IH,IN]),2),'y','Linewidth',2); hold on;
% % % % Isolated
% plot(TM0,sum(YM0(:,[QN]),2),'r','Linewidth',2); hold on;
% plot(TM,sum(YM(:,[QN]),2),'m','Linewidth',2); hold on;
% plot(TML,sum(YML(:,[QN]),2),'y','Linewidth',2); hold on;
% % % % % % All
% plot(TM0,sum(YM0(:,[EI,IA,IH,IN,QH,QN]),2),'k','Linewidth',2); hold on;
% plot(TM,sum(YM(:,[EI,IA,IH,IN,QH,QN]),2),'b','Linewidth',2); hold on;
% plot(TML,sum(YML(:,[EI,IA,IH,IN,QH,QN]),2),'g','Linewidth',2); hold on;


end
