function [beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,delta,mh,mueH,psiH,mc,mueC,psiC,P]=ParameterOutput(Amin,R0E,wr,lockdown)
%% PARAMETEROUTPUT returns the parameters based on the number of age classes
%specified in the model
% Input
% Amin - The minimum age of the different classes
% R0E  - R0 to be calibrated to
% wr   - location index (1-Mumbai,2-Nagpur,3-Delhi,4-Kolkata,5-Pune, 6-India)
% lockdown - 1/0 Yes/No
% Output
%beta  - probability of infection
%sigma - rate from infection to symptoms (Susc.->PreSym, PreSym->)
%kA    - relativity infectivity of asymptomatic infections
%kM    - relativity infectivity of mild infections
%M     - contact matrix (Size: AxA)
%M2    - contact matrix home (Size: AxA)
%gamma - rate to recovery symptomatic individual
%a     - proportion of asymptomatic infections
%q     - proportion of cases being quarantined
%h     - proportion of symptomatic cases being hospitalized
%delta - hospitalization rate
%mh    - rate percentage for mortality in hospital
%mueH  - mortality rate in hospital
%psiH  - recovery rate from hosptial
%mc    - rate percentage for mortality in ICU
%mueC  - mortality rate in ICU
%psiC  - recover rate from ICU
%P     - population size

%% Paramter specification
kA = 0.5;
kM = 0.5;
sigma=[1/2.9,1/2.3]; % 1/sigma = 1/sigma1 + 1/sigma2
tau=1; % not being used
gamma= 1/4.6;
a = 0.28;
q= 0.05;
f=0.0; % not being used
h=[0.025, 0.32, 0.32, 0.64]'; %updated
c=[0.014, 0.042, 0.075, 0.15]'; %updated
delta=1/3.5;
mh= 0.2296;
mueH = 1/9.7;
psiH = 1/10;
mc= 0.1396;
mueC= 1/7;
psiC= 1/13.25;
[M,M2,P]=DemoIndia(Amin,2*wr,lockdown);
beta = getBeta(R0E,P,sigma,h,gamma,delta,M,kM,kA,a);
%beta=CalcR0(R0E,P,sigma(1),h,gamma,delta,M,kM,kA,a);
end
