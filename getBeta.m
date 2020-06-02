function betaE=getBeta(R0E,P,sigma,h,gamma,delta,M,kM,kA,a)
%% betaE=CalcR0(R0E,N,sigma,h,gamma,delta,M,xi,s)
% Calibrates the value for beta in the model for a given R0
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%R0E - The basic reproductive number wanted for the model
%P - Population vector for the different age classes
%sigma - the rate from incubation period to symptomatic infectious period
%h - Age dependent hospitalization
%gamma - the rate of recovery
%delta - the rate to hospitalization
%M - The contact matrix for the community
%kappa - Relative infectivity of cases exhibiting mild
%symptoms
%theta - vector of proportion of cases exhibiting mild symptoms
% lb - the lower specified bound for searching beta
% ub - the lower specified bound for searching beta
% NS - Number of points used in the linear search
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% betaE - Estimated value of beta

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calcuation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lb= 0.001;
ub= 0.1;
NS= 1000;
betav=linspace(lb,ub,NS); % Vector spanning the search criteria for the value of beta
R0=zeros(NS,1); % The values of R0 for the corresponding betaV

for rr=1:NS
    beta=betav(rr);
    R0(rr)= getR0(beta,P,sigma,h,gamma,delta,M,kM,kA,a);
end
% Interpolation to determine that value of betaE
betaE=pchip(R0,betav,R0E);
% Determine the it falls within the bounds specified for the search
for jj=1:length(betaE)
    if((betaE(jj)>ub)||(betaE(jj)<lb))
        betaE(jj)=NaN;
    end
end
end
