clear;
close all;
Amin=[0 20 50 65];
A=length(Amin);
R0E=2;
[beta,sigma,tau,M,M2,gamma,q,h,f,c,delta,mh,mueH,psiH,mc,mueC,psiC,P]=ParameterOutput(Amin,R0E);
IC=zeros(8*A,1);
IC(1:A)=P;
IC(2)=IC(2)-5;
IC(A+2)=5;
N=2500;
rng('shuffle');
TTv=zeros(N,4);
HCv=zeros(N,4);
tauv=[0.5 1 1.5 2];
BedsR=round(round(sum(P)*2.2/1000)*0.06);

for mm=1:4
    tau=tauv(mm);
    TT=zeros(N,1);
    HC=zeros(N,1);
    parfor jj=1:N
        [TT(jj),HC(jj)]=StochSystem(300,IC,beta,sigma,tau,M,M2,gamma,q,h,f,c,delta,mh,mueH,psiH,mc,mueC,psiC,P,A,BedsR);    
    end
    TTv(:,mm)=TT;
    HCv(:,mm)=HC;
end
