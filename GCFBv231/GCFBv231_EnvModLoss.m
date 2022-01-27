%
%       Reduction of Envelope Modulation working with GCFBv230
%       IRINO, T.
%       Created:  10 Feb 2021
%       Modified:  10 Feb 2021
%       Modified:  11 Feb 2021
%       Modified:  14 Feb 2021
%
%
%
function [EMframe, EMparam]  = GCFBv231_EnvModLoss(cGCframe,GCparam,EMparam)

if strncmp(GCparam.DynHPAF.StrPrc,'frame',5) ~= 1
    error('Working only when GCparam.DynHPAF.StrPrc== ''frame-base''');
end;

%% %%%%%%%%%
% Parameter setting
%%%%%%%%%%%
% GCparam.HLoss.FaudgramList �Ɠ��������̃p�����[�^���K�v
% 1�̒l�iscalar�j�Ȃ�Avector�ɕϊ�
%
LenFag = length(GCparam.HLoss.FaudgramList);
EMparam.fs = GCparam.DynHPAF.fs;  % frame-base�̏o��sampling-rate

if isfield(EMparam,'ReducedB') == 0  % default
    EMparam.ReducedB = zeros(1,LenFag);
end
if length(EMparam.ReducedB) == 1
    EMparam.ReducedB = EMparam.ReducedB*ones(1,LenFag);
elseif length(EMparam.ReducedB) ~= LenFag
    error('Set EMparam.ReducedB at FaudgramList in advance.');
end

if isfield(EMparam,'Fcutoff') == 0 % default: almost no cutoff
    EMparam.Fcutoff = 0.999*EMparam.fs/2*ones(1,LenFag);
end
if length(EMparam.Fcutoff) == 1
    EMparam.Fcutoff = EMparam.Fcutoff*ones(1,LenFag);
elseif length(EMparam.Fcutoff) ~= LenFag
    error('Set EMparam.Fcutoff at FaudgramList in advance.');
end

%%%%%%
% FB ����
%%%%%%%
% interporation to GCresp.Fr1 (which is closer to Fp2)
[ERBrateFag] = Freq2ERB(GCparam.HLoss.FaudgramList);
[ERBrateFr1] = Freq2ERB(GCparam.Fr1); % GC channel��
EMparam.FB_Fr1            = GCparam.Fr1; % GCFBv230_SetParam�ő������Ă���
EMparam.FB_ReducedB = interp1(ERBrateFag,EMparam.ReducedB, ERBrateFr1,'linear','extrap');
EMparam.FB_Fcutoff     = interp1(ERBrateFag,EMparam.Fcutoff, ERBrateFr1,'linear','extrap');

%% %%%%%%%%%%%%%%%%%%%%%%%
% Main: filtering
%%%%%%%%%%%%%%%%%%%%%%%%%
EMframe  = zeros(size(cGCframe));
EMparam.orderLPF = 1;  %   TMTF is a first-order low-pass filter.�@  ����ȊO�́A�󂯕t���Ȃ��B
EMparam.SampleDelay = 1;  % 1st order�̎�  Sample delay��1.  see testTMTFlpf.m

EMparam.fcSepFilt      = 1;  % DC vs High freq :Separation filter
EMparam.orderSepFilt = 2;
NormSepFiltCutoff = EMparam.fcSepFilt/(EMparam.fs/2);
[bzSepLP, apSepLP] = butter(EMparam.orderSepFilt,NormSepFiltCutoff);
[bzSepHP, apSepHP] = butter(EMparam.orderSepFilt,NormSepFiltCutoff,'high');

SwMethod = 1; % RMS    separation of DC component only
% Not very good:   SwMethod = 2; % Lowpass-Highpass separation

for nch = 1:GCparam.NumCh
    Env = cGCframe(nch,:);
    if SwMethod == 1,
        EnvSepLP = sqrt(mean(Env.^2)); % DC component
        EnvSepHP = Env-EnvSepLP;
    else
        EnvSepLP =  filter(bzSepLP, apSepLP,Env);  % Env Separated by LPF:  No gain control
        EnvSepHP =  filter(bzSepHP, apSepHP,Env);  % Env Separated by HPF : Gain & LPF are applied.
    end;
    
    % Lowpass of  Env separated by HPF
    NormFcutoff = EMparam.FB_Fcutoff(nch)/(EMparam.fs/2);
    [bz, ap] = butter(EMparam.orderLPF,NormFcutoff);
    EnvSepHP2 = filter(bz, ap, EnvSepHP);
    EnvSepHP2 = 10^(-EMparam.FB_ReducedB(nch)/20)*EnvSepHP2;  % filter gain��reducedB������������
    
    EnvRdct = EnvSepHP2 + EnvSepLP; % ���킹��
    
    % compensation of filter delay
    NumCmpnst = EMparam.SampleDelay;  % Sample delay�ŕ␳
    EMframe(nch,:) = [ EnvRdct((NumCmpnst+1):end), zeros(1,NumCmpnst)];
    
end

return


%% %%%%%%%%%
% Trash
%%%%%%%%%%%
% [bz, ap] = butter(EMparam.orderLPF,NormFcutoff);
% if ap(1) ~= 1, % �ʏ�P�̂͂�
%     warning('Something strange in butter');
%     bz = bz/ap(1);
%     ap = ap/ap(1);
% end;

%
%     RmsEnv = sqrt(mean(Env.^2));  % Rms value of Env. for equalization
% EnvNoDC = Env - RmsEnv;   % DC���������� -- ����́A�ρBDC���������傫�����̂܂�
% �S�̂�TMTF gain������ƍl���Ă悢�B
%    EnvRdct = EnvRdct+ RmsEnv;    % DC���������ǂ��B


