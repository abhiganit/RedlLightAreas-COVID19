WR = [1,2,3,4,5,6]; % which Red Light Area
R0 = [1.75,2,2.25,2.5]; % Different values of R0

TM0 = {}; YM0 = {}; TM={}; YM={}; TML={}; YML ={}; Pop={};
i = 1;
for wr = WR;
    j = 1;
    for r0 = R0;
        [TM0{i}{j},YM0{i}{j},TM{i}{j},...
         YM{i}{j},TML{i}{j},YML{i}{j},Pop{i}{j}] = ...
            RunSimA(wr,r0);
        j=j+1;
    end
    i=i+1;
end

%% Index for dxdt and x to make readability of code easier
A = 4; Ss = 2;
S=     [1:A*Ss];    % Susceptible
E=   A*Ss+[1:A*Ss]; % Incubation
IA=2*A*Ss+[1:A*Ss]; % Asymptomatic infections
IH=3*A*Ss+[1:A*Ss]; % Symptomatic severe infections (not isolated)
IN=4*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
QH=5*A*Ss+[1:A*Ss]; % Symptomatic severe infections (isolated)
QN=6*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
H= 7*A*Ss+[1:A*Ss]; % Hospitalization
C= 8*A*Ss+[1:A*Ss]; % Need ICU
D= 9*A*Ss+[1:A*Ss]; % Deaths
CC = 10*A*Ss+[1:A*Ss]; % Cumulative cases
ER= 11*A*Ss+[1:A*Ss]; % Incubation
IAR=12*A*Ss+[1:A*Ss]; % Asymptomatic infections
IHR= 13*A*Ss+[1:A*Ss]; % Symptomatic severe infections (not isolated)
INR=14*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
QHR=15*A*Ss+[1:A*Ss]; % Symptomatic severe infections (isolated)
QNR=16*A*Ss+[1:A*Ss]; % Symptomatic mild infections (not isolated)
HR= 17*A*Ss+[1:A*Ss]; % Hospitalization
CR= 18*A*Ss+[1:A*Ss]; % Need ICU
DR= 19*A*Ss+[1:A*Ss]; % Deaths
CCR=20*A*Ss+[1:A*Ss];% Cumulative number of cases due to Red light area


S1 = S(1:4); S2 = S(5:end);
E1 = E(1:4); E2 = E(5:end);
IA1 = IA(1:4); IA2 = IA(5:end);
IH1 = IH(1:4); IH2 = IH(5:end);
IN1 = IN(1:4); IN2 = IN(5:end);
QH1 = QH(1:4); QH2 = QH(5:end);
QN1 = QN(1:4); QN2 = QN(5:end);
H1 = H(1:4); H2 = H(5:end);
C1 = C(1:4); C2 = C(5:end);
D1 = D(1:4); D2 = D(5:end);
CC1 = CC(1:4); CC2 = CC(5:end);


% Calculate delay in peaks under different scenarios
st = 1; en = 366;
stl = 15; enl = 50;

% delay in peaks
Dl = [];
for i = 1:6; % varying over RLAs
    for j = 1:4; %varying over R0
        yM = YM{i}{j};
        yML = YML{i}{j};
        [v0,ix0] = max(sum(yM(st:en,[IA IH IN QH QN]),2));
        [vL,ixL] = max(sum(yML(st:en,[IA IH IN QH QN]),2));
        Dl(i,j) = ixL - ix0;
    end
end


% difference in peaks
Pl = []; %zeros(5,5);
for i = 1:6; % varying over RLAs
    for j = 1:4; % varying over R0
        yM = YM{i}{j};
        yML = YML{i}{j};
        [v0,ix0] = max(sum(yM(st:en,[IA IH IN QH QN]),2));
        [vL,ixL] = max(sum(yML(st:en,[IA IH IN QH QN]),2));
        Pl(i,j) = v0 - vL;
    end
end


% cases averted originating from Red Light Areas
Cs = [];

for i = 1:6; % varying over RLAs
    for j = 1:4; % varying over R0
        yM = YM{i}{j};
        yML = YML{i}{j};
        [v0,ix0] = max(sum(yM(st:en,[CCR]),2));
        [vL,ixL] = max(sum(yML(st:en,[CCR]),2));
        Cs(i,j) = v0 - vL;
    end
end

% deaths averted originating from Red Light Areas
Ds = [];

for i = 1:6; % varying over RLAs
    for j = 1:4; % varying over R0
        yM = YM{i}{j};
        yML = YML{i}{j};
        [v0,ix0] = max(sum(yM(st:en,[DR]),2));
        [vL,ixL] = max(sum(yML(st:en,[DR]),2));
        Ds(i,j) = v0 - vL;
    end
end




%% Save data as matfile to read in python
locations = {'Mumbai','Nagpur','Delhi','Kolkata','Pune','India'};
for i = 1:6
    Cases = []; CasesR = []; CasesPC = []; CasesRPC = [];
    CLR = []; DLR = []; CumCases = []; CumCasesR = [];
    Hosp = []; HospR = [];
    Deaths = []; DeathsR = [];
    for k = 1:4 % varying over R0
        tM0 = TM0{i}{k}; tM = TM{i}{k}; tML = TML{i}{k};
        yM0 = YM0{i}{k}; yM = YM{i}{k}; yML = YML{i}{k};
        PopA = sum(Pop{i}{k});
        PopR = sum(Pop{i}{k}(5:8));
        t = {tM0,tM,tML}; y = {yM0,yM,yML};
        for j = 1:3
            Cases = [Cases,sum(y{j}(st:en,[IA IH IN QH QN]),2)];
            CasesPC = [CasesPC,1000*sum(y{j}(st:en,[IA IH IN QH QN]),2)/ ...
                       PopA];
            CasesR = [CasesR,1000*sum(y{j}(st:en,[IA2 IH2 IN2 QH2 QN2]),2)/PopR];
            CasesRPC = [CasesRPC,1000*sum(y{j}(st:en,[IA2 IH2 IN2 ...
                                QH2 QN2]),2)/PopR];
            CumCases = [CumCases,sum(y{j}(st:en,[CC]),2)];
            CumCasesR = [CumCasesR,sum(y{j}(st:en,[CC2]),2)];
            Deaths = [Deaths,sum(y{j}(st:en,[D]),2)];
            DeathsR = [DeathsR,sum(y{j}(st:en,[D2]),2)];
            Hosp = [Hosp,sum(y{j}(st:en,[H,C]),2)];
            HospR = [HospR,sum(y{j}(st:en,[H2,C2]),2)];
            CLR = [CLR,sum(y{j}(st:en,[CCR]),2)];
            DLR = [DLR,sum(y{j}(st:en,[DR]),2)];
        end
    end
Cases = Cases(2:end,:); CasesPC = CasesPC(2:end,:);
CasesR = CasesR(2:end,:); CasesRPC = CasesRPC(2:end,:);
CumCases = CumCases(2:end,:); CumCasesR = CumCasesR(2:end,:);
Deaths = Deaths(2:end,:); DeathsR = DeathsR(2:end,:);
Hosp = Hosp(2:end,:); HospR = HospR(2:end,:);
CLR = CLR(2:end,:); DLR = DLR(2:end,:);

filename = strcat(locations{i},'.mat');
save(filename,'Cases','CasesPC','CasesR','CasesRPC','CLR','DLR','CumCases','CumCasesR','Hosp','HospR','Deaths','DeathsR');
end

% save summary
save('summary.mat','Dl','Pl','Cs','Ds');
