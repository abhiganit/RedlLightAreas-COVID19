function dxdt = ASODE(t,x,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,delta,mh,mueH,psiH,mc,mueC,psiC,P,A,Ss,CM,tm)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computational Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the vector and specify the index equations
dxdt=zeros(length(x),1);

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



%% Convert age-dependent parameters to account for all state together
h = repmat(h,Ss,1);
c = repmat(c,Ss,1);

% Probability of infection matrix and contact pattern multiplier
B = beta*[1,tm;tm,1];
B = repelem(B,A,A);

% Probability of infection applied to contact patterns
M = B.*M;

% Probability of infection applied to contact patterns for isolated class
M2 = beta.*M2;

delta1 = delta; %1/(1/delta - 1/tau);
gamma1 = gamma; % 1/(1/gamma - 1/tau);

%% Susceptible and vaccinated population
dxdt(S)= -(kA*M*x(IA)./P + kM*M*x(IN)./P ...
           + M*x(EI)./P + M*x(IH)./P+kM*M2*x(QN)./P+M2*x(QH)./P).*x(S);

%% Incubation period population
dxdt(E)= (kA*M*x(IA)./P + kM*M*x(IN)./P ...
              + M*x(EI)./P + M*x(IH)./P+kM*M2*x(QN)./P+M2*x(QH)./P).*x(S)-sigma(1).*x(E);

%% Pre-Symptomatic
dxdt(EI) = sigma(1).*x(E) - sigma(2).*x(EI);

%% Asymptomatic infections
dxdt(IA) = a.*sigma(2).*x(EI) - gamma.*x(IA);

%% Symptomatic and not isolated
% Severe
dxdt(IH)=(1-a).*(1-q).*h.*sigma(2).*x(EI) -f.*tau.*x(IH)-(1-f).*delta.*x(IH);
% Mild
dxdt(IN)=(1-a).*(1-q).*(1-h).*sigma(2).*x(EI)-f.*tau.*x(IN)-(1-f).*gamma.*x(IN);

%% Symptomatic and isolated (ISI,IMI)
% Severe
dxdt(QH)=(1-a)*q.*h.*sigma(2).*x(EI) + f.*tau.*x(IH) -delta1.*x(QH);
% Mild
dxdt(QN)=(1-a)*q.*(1-h).*sigma(2).*x(EI)+f.*tau.*x(IN)-gamma1.*x(QN);

%% Hospital
dxdt(H)=(1-c).*delta1.*x(QH)+(1-f).*(1-c).*delta.*x(IH)-(1-mh).*psiH.*x(H)-mh.*mueH.*x(H);
%% ICU
dxdt(C)=c.*delta1.*x(QH)+(1-f).*c.*delta.*x(IH)-(1-mc).*psiC.*x(C)-mc.*mueC.*x(C);

%% Deaths
dxdt(D) = mh.*mueH.*x(H) + mc.* mueC.*x(C);

%% Cumulative cases
dxdt(CC) = (kA*M*x(IA)./P + kM*M*x(IN)./P ...
    + M*x(IH)./P+kM*M2*x(QN)./P+M2*x(QH)./P).*x(S);
%
%% Cumulative hospitalization
dxdt(CH) = (1-c).*delta1.*x(QH)+(1-f).*(1-c).*delta.*x(IH);

%% Cumulative ICU admissions
dxdt(CI) = c.*delta1.*x(QH)+(1-f).*c.*delta.*x(IH);

%% To fit
dxdt(CF) = (kA*M*x(IA)./P + kM*M*x(IN)./P ...
    +  M*x(IH)./P+kM*M2*x(QN)./P+M2*x(QH)./P).*x(S);




end
