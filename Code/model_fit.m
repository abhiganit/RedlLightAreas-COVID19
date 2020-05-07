%% Index for dxdt and x to make readability of code easier
A = 4; Ss = 2;


S=     [1:A*Ss]; % Susceptible
E=   A*Ss+[1:A*Ss]; % Incubation
EI=2*A*Ss+[1:A*Ss]; % Incubation
IA=3*A*Ss+[1:A*Ss]; % Asymptomatic infections
IH=4*A*Ss+[1:A*Ss]; % Symptomatic severe infections (not isolated)
IN=5*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
QH=6*A*Ss+[1:A*Ss]; % Symptomatic severe infections (isolated)
QN=7*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
H= 8*A*Ss+[1:A*Ss]; % Hospitalization
C= 9*A*Ss+[1:A*Ss]; % Need ICU
D= 10*A*Ss+[1:A*Ss]; % Deaths
CC=11*A*Ss+[1:A*Ss];% Cumulative cases
CH=12*A*Ss+[1:A*Ss];
CI=13*A*Ss+[1:A*Ss];
CF=14*A*Ss+[1:A*Ss];


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

% load observed data
load observed_data

fits = zeros(6,4);
R0 = [1.75,2,2.25,2.5]; % Different values of R0
for i = 1:6
    for j = 1:4
        wr = i; % Choose location
        r0 = R0(j); % Choose R0 value
        init = 0.04;
        lb = 0;
        ub = 1;
        f = @(x)get_likelihood(x,r0,wr);
        fit = fminsearchbnd(f,init,lb,ub)
        fits(i,j) = fit;
        % check model fit?
        [TM0,YM0,TM,YM,TML,YML,Pop] = RunSimA(wr,r0,fit);

        tm = TM(1:41);
        ym = sum(YM(1:41,[CF]),2);

        yo = df(:,wr+1);
        to = df(:,1);

        % Plot fit
        plot(tm,ym,'b',to,yo,'ro')
    end
end
