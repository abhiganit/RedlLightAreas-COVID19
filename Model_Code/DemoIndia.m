function [M,M2,P] = DemoIndia(Amin,State,lockdown)
% Returns contact matrix for community and home based on specified
% compression
% Input
% Amin - The minimum age of the different classes
% State - location index
% lockdown - 1/0, Yes/No
% Output
%M - contact matrix (Size: AxA)
%M2 - contact matrix home (Size: AxA)
%P -Population size

% Read age-distributed population
% Read India's demographic data

load IndiaDemo
PFull = Pop_Dist(:,State);

AA=5.*[0:(length(PFull)-1)];
Findx=cell(length(Amin),1);
F80indx=cell(length(Amin),1);
for ii=1:length(Amin)-1
    gg=find(AA==Amin(ii));
    hh=find(AA==Amin(ii+1));
    Findx{ii}=[gg:(hh-1)];
    F80indx{ii}=[gg:(hh-1)];
end
Findx{ii+1}=hh:length(PFull);
gg=find(AA==Amin(end));
hh=find(AA==80);
F80indx{ii+1}=[gg:(hh-1)];

if lockdown ==0
    MFull = Contacts.All;
else
    MFull = Contacts.Home;
end
M2Full = Contacts.Home;

% Convert Population and Contact matrices to match with number of
% age-groups being considered (Amin)
P=zeros(length(Amin),1);
Ptemp=zeros(length(MFull(:,1)),length(Amin));

Mtemp=zeros(length(Amin),length(MFull(:,1)));
M2temp=zeros(length(Amin),length(MFull(:,1)));

for ii=1:length(P)
    P(ii)=sum(PFull([Findx{ii}]));
    Ptemp([F80indx{ii}],ii)=PFull([F80indx{ii}])./sum(PFull([F80indx{ii}]));
    Mtemp(ii,:)=sum(MFull([F80indx{ii}],:),1);
    M2temp(ii,:)=sum(M2Full([F80indx{ii}],:),1);
end

M=Mtemp*Ptemp;
M2=M2temp*Ptemp;

M=(M+M')./2;
M2=(M2+M2')./2;

end
