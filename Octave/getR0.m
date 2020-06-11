function R0 = getR0(beta,P,sigma,h,gamma,delta,M,kM,kA,a)
%% Calculates value of reproductive number using Next Generation Matrix method

%% Input parameters
% # beta  - prob. of infection
% # P     - (4x1) population
% # S     - (4x1) suceptible population
% # sigma - (1/incubation-non inf, 1/incubation inf)
% # h     - proportion of cases needing hospitalization
% # gamma - recovery rate
% # delta - rate of hospitalization
% # M     - general contact pattern
% # kM    - relative infectivity of mild with respect to severe
% # kA    - relative infectivity of asym. with respect to severe
% # a     - proportion of asymptomatic

%% Infected compartments of the model
% # E  - (4x1) Exposed
% # EI - (4x1) Pre-symptomatic
% # IA - (4x1) Asymptomatic
% # IS - (4x1) Severe note:assume during beginning of epidemic no
%            quarantine
% # IM - (4x1) Mild note:assume during beginning of epidemic no
%            quarantine

%% Equations for infected
%  E  =  - \sigma_1 E  + \beta (M (E_I/P) + kA M (I_A/P) + M (I_S/P) + k_M M
% (I_M/P))S

%  E_I  = \sigma_1 E - \sigma_2 E_I + 0(I_A + I_S + I_M)

%  IA   = 0 E + a \sigma_2 E_I - \gamma I_A + 0 (I_S + I_M)

%  IS   = 0 E + (1-a) h \sigma_2 E_I + 0 I_A - \delta I_S + 0 I_M

%  IM   = 0 E + (1-a) (1-h) \simga_2 E_I + 0(I_A+I_S) - \gamma I_M

%% Construction of Next generation matrix
%%% F_{i,j}: New infections in i due to j
% E (4x1)    Different groups of incubation do not infect each other
E = zeros(4,4);
% E_I (4x1)  \beta (M (E_I/P) S
% DFE. S = P & E_I = 1
EI = beta*M.*repmat(P,1,4)./P';
% IA (4x1) \beta kA M (I_A/P)
IA = beta*kA*M.*repmat(P,1,4)./P';
% IS (4x1) \beta M (I_A/P)
IS = beta*M.*repmat(P,1,4)./P';
% IM (4x1) \beta kA M (I_A/P)
IM = beta*kM*M.*repmat(P,1,4)./P';

F = [E,EI,IA,IS,IM];

F = [F;zeros(size(F,2)-size(F,1),size(F,2))];

%%% V_{i,j}: Transition rates
V = zeros(size(F));
% E -> +/-  E, EI IA, IS, IM
% -sigma1 E + 0 (IA, IS, IM)
for i = 1:4  % updating over all row for column 1-4(E)
    V(i,i) = -sigma(1);
    V(i+4,i) = sigma(1);
end

% EI -> +/-  E, EI, IA, IS, IM
nh = (1-h);
for i = 5:8 % updating over all row for column 5-8(EI)
    V(i,i) = -sigma(2);
    V(i+4,i) = a*sigma(2);
    V(i+8,i) = (1-a)*h(i-4)*sigma(2);
    V(i+12,i)= (1-a)*nh(i-4)*sigma(2);
end

% IA -> +/-  E, EI, IA, IS, IM
for i = 9:12
    V(i,i) = -gamma;
end

% IS -> +/-  E, EI, IA, IS, IM
for i = 13:16
    V(i,i) = -delta;
end

% IS -> +/-  E, EI, IA, IS, IM
for i = 17:20
    V(i,i) = -gamma;
end

%% NGM =  - F*inv(V)
NGM = -F*inv(V);

R0 = max(abs(eig(NGM)));
