%
%   test ReductModEnv
%   Irino, T.
%   Created:    7 Feb 2021
%   Modified:   7 Feb 2021
%   Modified:   9 Feb 2021
%
clear
clf

Tsnd = 1;
EMparam.fs = 2000;
EMparam.fcutoff = 256;
% ���̃f�[�^���ALPF�ō��
rng(1234);
LenEnv = EMparam.fs*Tsnd;
Env0 = randn(1,EMparam.fs*Tsnd) + 10;
%Env0 = [zeros(1,20), 1, zeros(1,LenEnv-11)];
Env = ReduceEnvMod(Env0,EMparam);   
% ����Ɉȉ��ŁAreduction

EMparam.fcutoff = 64;
%EMparam.orderLPF = 5; % �قƂ�Ǖς��Ȃ��B�ύX����K�v�Ȃ��B

cnt =0;
for reductdB = [0 10 20]
    cnt = cnt +1;
    subplot(3,1,cnt);
    EMparam.reductdB = reductdB;
    %tic
    [EnvRdct EMparam] = ReduceEnvMod(Env,EMparam);
    % toc
    nSt = 1;
    RmsEnv(1,cnt) = sqrt(mean(Env(nSt:end).^2));
    RmsEnv(2,cnt) = sqrt(mean(EnvRdct(nSt:end).^2));
    
    LenEnv = length(Env);
    tms = (0:LenEnv-1)/EMparam.fs*1000;
    nPl = 200:400;
    nPl = 1:100;
    %nPl = 1:LenEnv;
    % nPl = LenEnv+(-50:0);
    % plot(tms(nPl),Env(nPl), tms(nPl),RdctEnv(nPl));
    xlabel('Time (ms)');
    plot(nPl, Env0(nPl),nPl,Env(nPl), nPl,EnvRdct(nPl));
    xlabel('Sample');
    ylabel('Amplitude');
    grid on
end;

RmsEnv
ErrordB = 20*log10(RmsEnv(2,:)./RmsEnv(1,:))
EMparam

