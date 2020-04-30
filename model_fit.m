%% Index for dxdt and x to make readability of code easier
A = 4; Ss = 2;

S=     [1:A*Ss]; % Susceptible
E=   A*Ss+[1:A*Ss]; % Incubation
IA=2*A*Ss+[1:A*Ss]; % Asymptomatic infections
IH=3*A*Ss+[1:A*Ss]; % Symptomatic severe infections (not isolated)
IN=4*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
QH=5*A*Ss+[1:A*Ss]; % Symptomatic severe infections (isolated)
QN=6*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
H= 7*A*Ss+[1:A*Ss]; % Hospitalization
C= 8*A*Ss+[1:A*Ss]; % Need ICU
D= 9*A*Ss+[1:A*Ss]; % Deaths
CC=10*A*Ss+[1:A*Ss];% Cumulative cases
CH=11*A*Ss+[1:A*Ss];
CI=12*A*Ss+[1:A*Ss];


S1 = S(1:4); S2 = S(5:end);
E1 = E(1:4); E2 = E(5:end);
%EI1 = EI(1:4); EI2 = EI(5:end);
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

% load observed data
load observed_data

fits = []
for i = 1:6
    wr = i; % Choose location
    r0 = 2; % Choose R0 value
    init = 0.04;
    lb = 0;
    ub = 1;
    f = @(x)get_likelihood(x,r0,wr);
    fit = fminsearchbnd(f,init,lb,ub);
    fits = [fits,fit];

    % check model fit?
    [TM0,YM0,TM,YM,TML,YML,Pop] = RunSimA(wr,r0,fit);

    tm = TM(1:41);
    ym = sum(YM(1:41,[CH]),2);

    yo = df(:,wr+1);
    to = df(:,1);

    % Plot fit
    close all;
    plot(tm,ym,'b',to,yo,'ro')
end


% Separate
st = 1; en = 365;
t = {TM0,TM,TML}; y = {YM0,YM,YML};
colorG = {'k-','b-','g-'};
colorR = {'ko','bo','go'};
xpos = -40;
PopA = sum(Pop);
PopR = sum(Pop(5:8));

close all;
fig = figure('position',[300,200,1400,1200]);%,'visible','off');
subplot(2,1,1);
for j = 1:3
     city = (sum(y{j}(st:en,[IA IH IN QH QN]),2));
     plot(t{j}(st:en),...
          city,colorG{j}, ...
          'LineWidth',2); hold on;
end
subplot(2,1,2);
for j = 1:3
     rla = (sum(y{j}(st:en,[IA2 IH2 IN2 QH2 QN2]),2))
     plot(t{j}(st:en),...
          rla,...
          colorR{j}, 'LineWidth',1,'MarkerSize',4); hold on;
end



% Together
for j = 1:3
     city = (sum(y{j}(st:en,[IA IH IN QH QN]),2));
     rla = (sum(y{j}(st:en,[IA2 IH2 IN2 QH2 QN2]),2))
     plot(t{j}(st:en),...
          1000*city/PopA,colorG{j}, ...
          'LineWidth',2);
          hold on;
     plot(t{j}(st:en),...
          1000*rla/PopR,...
          colorR{j}, 'LineWidth',1,'MarkerSize',4);

 end
