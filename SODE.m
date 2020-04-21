function dxdt = SODE(t,x,beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,delta,mh,mueH,psiH,mc,mueC,psiC,P,A)
%% dxdt = SODE()
% System of ODE to run the model for vaccination and contact tracing
%% Input parameters
%t    - time variable
%x    - State variable
%       S=     [1:A]; % Susceptible
%       E=   A+[1:A]; % Incubation
%       IA=2*A+[1:A]; % Asymptomatic infections
%       IH=3*A+[1:A]; % Symptomatic severe infections (not isolated)
%       IN=4*A+[1:A]; % Symptomatic mild infections (not isolated)
%       QH=5*A+[1:A]; % Symptomatic severe infections (isolated)
%       QN=6*A+[1:A]; % Symptomatic mild infections (not isolated)
%       H= 7*A+[1:A]; % Hospitalization
%       C= 8*A+[1:A]; % Need ICU
%       D= 9*A+[1:A]; % Deaths

%beta  - probability of infection
%kA    - relative infectivity of asymptomatic cases
%kM    - relative infectivity of mild cases
%sigma - rate from infection to symptoms
%tau   - contact tracing rate
%M     - contact matrix (Size: AxA)
%M2    - contact matrix home (Size: AxA)
%gamma - rate to recovery
%a     - proportion of asymptomatic cases
%q     - proportion of infections becoming isolated on symptoms onset
%h     - proportion of infections that are severe (need hospitalization)
%f     - proportion of non-isolated moving to isolated
%delta - hospitalization rate
%mh    - rate percentage for mortality in hospital
%mueH  - mortality rate in hospital
%psiH  - recovery rate from hosptial
%mc    - rate percentage for mortality in ICU
%mueC  - mortality rate in ICU
%psiC  - recover rate from ICU
%P     - population size
%A     - number of ages classes considered
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computational Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialize the vector and specify the index equations
dxdt=zeros(length(x),1);

%% Compartments
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

%% Susceptible and vaccinated population
dxdt(S)= -beta.*(kA*M*x(IA)./P + kM*M*x(IN)./P ...
                 + M*x(IH)./P+kM*M2*x(QN)./P+M2*x(QH)./P).*x(S);

%% Incubation period population
dxdt(E)= beta.*(kA*M*x(IA)./P + kM*M*x(IN)./P ...
                 + M*x(IH)./P+kM*M2*x(QN)./P+M2*x(QH)./P).*x(S)-sigma.*x(E);
%% Asymptomatic infections
dxdt(IA) = a.*sigma.*x(E) - gamma.*x(IA);

%% Symptomatic and not isolated
% Severe
dxdt(IH)=(1-a).*(1-q).*h.*sigma.*x(E) -f.*tau.*x(IH)-(1-f).*delta.*x(IH);
% Mild
dxdt(IN)=(1-a).*(1-q).*(1-h).*sigma.*x(E)-f.*tau.*x(IN)-(1-f).*gamma.*x(IN);
%% Symptomatic and isolated (ISI,IMI)
% Severe
dxdt(QH)=(1-a)*q.*h.*sigma.*x(E) + f.*tau.*x(IH) -delta.*x(QH);
% Mild
dxdt(QN)=(1-a)*q.*(1-h).*sigma.*x(E)+f.*tau.*x(IN)-gamma.*x(QN);

%% Hospital
dxdt(H)=(1-c).*delta.*x(QH)+(1-f).*(1-c).*delta.*x(IH)-(1-mh).*psiH.*x(H)-mh.*mueH.*x(H);
%% ICU
dxdt(C)=c.*delta.*x(QH)+(1-f).*c.*delta.*x(IH)-(1-mc).*psiC.*x(C)-mc.*mueC.*x(C);

%% Deaths
dxdt(D) = mh.*mueH.*x(H) + mc.* mueC.*x(C);

end
