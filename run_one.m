%% Intialization
% Choose index for location to run.
wr = 6; % 1:Mumbai, 2:Nagpur,3:Delhi,4:Kolkata,5:Pune,6:India

R0 = [1.75,2,2.25,2.5];% Values of reproduction numbers
j = 2; % Choose index for R0 number to run.
r0 = R0(j);

% load estimate for initial prevalence from pre-fitted model saved
% as matfile: Fitting.mat
load Fitting

%% Run Simulation
% Run simulations under three scenarios:
% 1. No initial lockdown [tM0,yM0]
% 2. Initial lockdown followed by re-opening of RLAs [tM,yM]
% 3. Initial lockdown followed by extended closure of RLAs [tML,yML]
[tM0,yM0,tM,yM,tML,yML,pop] = RunSimA(wr,r0,fits(wr,j));

%% Plot results
%% Index for solutions to make readability of code easier
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

S1 = S(1:4); S2 = S(5:end);
E1 = E(1:4); E2 = E(5:end);
EI1 = EI(1:4); EI2 = EI(5:end);
IA1 = IA(1:4); IA2 = IA(5:end);
IH1 = IH(1:4); IH2 = IH(5:end);
IN1 = IN(1:4); IN2 = IN(5:end);
QH1 = QH(1:4); QH2 = QH(5:end);
QN1 = QN(1:4); QN2 = QN(5:end);
H1 = H(1:4); H2 = H(5:end);
C1 = C(1:4); C2 = C(5:end);
D1 = D(1:4); D2 = D(5:end);
CC1 = CC(1:4); CC2=CC(5:end);
CH1 = CH(1:4); CH2=CH(5:end);
CI1 = CI(1:4); CI2=CI(5:end);
CF1 = CF(1:4); CF2 = CF(5:end);

% make plot of cases over time.
PopA = sum(pop);
PopR = sum(pop(5:8));

st = 1; en = 366;
stl = 15; enl = 50;
filename = 'India'
t = {tM0,tM,tML}; y = {yM0,yM,yML};
colorG = {'k-','b-','g-'};
colorR = {'ko','bo','go'};
xpos = -40;
close all;
fig = figure('position',[300,200,1400,1200]);%,'visible','off');
subplot(2,1,1)
for j = 1:3
    plot(t{j}(st:en),...
         (sum(y{j}(st:en,[IH IN QH QN]),2)),colorG{j}, ...
         'LineWidth',2);
    hold on;
end
box off;
xlim([0,365]);
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
ylabel('Cases','Fontsize',20);
title('Citywide')
subplot(2,1,2)
for j = 1:3
    plot(t{j}(st:en),...
         (sum(y{j}(st:en,[IH2 IN2 QH2 QN2]),2)),...
         colorR{j}, 'LineWidth',1,'MarkerSize',4);
    hold on;
end
box off;
xlim([0,365]);
set(gca,'LineWidth',2,'tickdir','out','Fontsize',16);
title('Red-light area');
yp = ylabel('Cases','Fontsize',20);
pos = get(yp,'Pos');
xlabel('Days','Fontsize',20);
print(filename,'-dpng');
