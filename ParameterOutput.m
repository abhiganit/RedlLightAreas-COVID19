function [beta,kA,kM,sigma,tau,M,M2,gamma,a,q,h,f,c,delta,mh,mueH,psiH,mc,mueC,psiC,P]=ParameterOutput(Amin,R0E,State,lockdown)
%% PARAMETEROUTPUT returns the parameters based on the number of age classes
%specified in the model
% Input
% Amin - The minimum age of the different classes
% pd - probability of death in hospital
% Output
%beta  - probability of infection
%sigma - rate from infection to symptoms
%kA    - relativity infectivity of asymptomatic infections
%kM    - relativity infectivity of mild infections
%tau   - contact tracing rate
%M     - contact matrix (Size: AxA)
%M2    - contact matrix home (Size: AxA)
%gamma - rate to recovery symptomatic individual
%a     - proportion of asymptomatic infections
%q     - rate percentage of unvaccinated syptomatic case self-quaratine
%h     - rate percentage of unvaccinated symptatic case being hospitalized
%delta - hospitalization rate
%mh    - rate percentage for mortality in hospital
%mueH  - mortality rate in hospital
%psiH  - recover rate from hosptial
%mc    - rate percentage for mortality in ICU
%mueC  - mortality rate in ICU
%psiC  - recover rate from ICU
%P     - population size
%% Paramter specification
kA = 0.55;
kM = 0.55;
sigma=1/5.2; %1/4
tau=1/2;
gamma=1/4.6; %1/(2*(7.5-4));
a = 0.28;
q=0.05;
f=0.05;
h=[0.025, 0.32, 0.32, 0.64]'; %updated
c=[0.014, 0.042, 0.075, 0.15]'; %updated
delta=1/3.5;
mh= 0.2296;
mueH = 1/9.7;
psiH = 1/10;
mc= 0.1396;
mueC= 1/7;
psiC= 1/13.25;
[M,M2,P]=DemoIndia(Amin,State,lockdown);
beta=CalcR0(R0E,P,sigma,h,gamma,delta,M,kM,kA,a);
end
