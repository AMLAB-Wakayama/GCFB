%
%      Calculate GC Hearing Loss from GCFBv230
%       Irino, T.
%       Created:  21 May 2020
%       Modified: 21 May 2020
%       Modified: 22 May 2020
%       Modified: 23 May 2020
%       Modified: 18 Jul 2020 %�R�����g�����@nCH--> nCmprsHlth
%       Modified: 19 Jul 2020 %c��compression health��������悤�ɁB�i���܂܂ŁAfrat��CompressionHealth�������Ă����j
%       Modified:  24 Jul 2020  (IO function)
%       Modified:  26 Jul 2020  (full debug)
%       Modified:  23 Jan 2021 (Modification started)
%       Modified:  24 Jan 2021 (InternalCmpnstLeveldB = -7, FactCmpnst --> OK)
%       Modified:  10 Feb 2021 (HLval_ManualSet)
%       Modified:  17 Aug 2021 using Fr1query = Fag   ( NOT Fp1)
%       Modified:  25 Aug 2021 v231 �O�ʏ�������Table--> interp1
%       Modified:  29 Aug 2021 v231
%       Modified:   1 Sep 2021  v231 debug  HL_OHC+HL_IHC
%       Modified:   7 Oct  2021  v231 checking IOfunction errors
%       Modified:   7 Oct  2021  v231 OK for IOfunction
%       Modified:   5 Nov  2021 v231  Switch for perform SetHeaingLoss  solely
%
%    function [GCparam] = CalGCHearingLoss(GCparam,GCresp)
%            INPUT:    Necessary: GCparam.HLoss.FaudgramList, --.HearingLevel, --.CompressionHealth
%                           GCresp.Fp1
%           OUTPUT:  GCparam.HLoss :  PinLossdB_IHC, PinLossdB_OHC, FB_PinLossdB_IHC ...
%
% Note:  21 May 2020
%             ����:  pGC��NH�ł�HI listener�ł���ɓ����B�Ⴄ�̂�HP-AF�̂Ƃ���̂݁B
%
%
function [GCparam] = GCFBv231_HearingLoss(GCparam,GCresp)

[GCparam] = SetHearingLoss(GCparam); %�����ŁAHearing Loss�̐ݒ�����Ă���B���Ɋ֐��L��B
if nargin < 2
    disp(['--- ' mfilename ': Setting default hearing loss parameter and return. ---'])
    return; 
end

%%%%%%%%%%%%%%%%%%%%%%
%% setting parameters of hearing loss %%%%

GCparam.HLoss.CompressionHealth_InitVal = GCparam.HLoss.CompressionHealth; %�@�����l
GCparam.HLoss.CompressionHealth = GCparam.HLoss.CompressionHealth;            % �܂��͈�v������B�������audiogram�ɂ��ύX����

% Table���g�킸�ɎZ�o
LenFag = length(GCparam.HLoss.FaudgramList);
for nFag = 1:LenFag
    Fr1query = GCparam.HLoss.FaudgramList(nFag);
    HL0_PinCochleadB(nFag) = HL2PinCochlea(Fr1query,0);  % cochlear Input Level �ɕϊ��B�@Compensation of MidEar Trans. Func.
    CompressionHealth    = GCparam.HLoss.CompressionHealth(nFag);
    [dummy, HL0_IOfuncdB_CH1] = GCFBv231_AsymFuncInOut(GCparam,GCresp,Fr1query,1,HL0_PinCochleadB(nFag));
    PindB_OHCreduction                = GCFBv231_AsymFuncInOut_InvIOfunc(GCparam,GCresp,Fr1query,CompressionHealth,HL0_IOfuncdB_CH1);
    
    PinLossdB_OHC(nFag)  =  PindB_OHCreduction - HL0_PinCochleadB(nFag);   % HLossdB�͐��̐�
    PinLossdB_OHC_Init(nFag)  = PinLossdB_OHC(nFag);   % inital value of OHC Loss
     PinLossdB_IHC(nFag)    = max(GCparam.HLoss.HearingLeveldB(nFag) - PinLossdB_OHC(nFag),0);  % Boundary setting 0�ȉ��ɂȂ�Ȃ�
    % IOfuncLossdB_IHC(nFag) = 0; % default
    
    % NH�ȊO�ŁA�����ɂ��������ꍇ�AOHC��PinLossdB_OHC���Čv�Z�B
    if PinLossdB_IHC(nFag) == 0  && GCparam.HLoss.HearingLeveldB(nFag) > 0
        PinLossdB_OHC(nFag)  = GCparam.HLoss.HearingLeveldB(nFag) - PinLossdB_IHC(nFag);      % PinLossdB_OHC�����␳
        CmprsHlthList = [1:-0.1:0];
        for nCH = 1:length(CmprsHlthList)  % ���X11�_�F elps 0.025 sec���� -- ���Ȃ��B
            CmprsHlth = CmprsHlthList(nCH);
            PindB_CmprsHlthVal_Inv = GCFBv231_AsymFuncInOut_InvIOfunc(GCparam,GCresp,Fr1query,CmprsHlth,HL0_IOfuncdB_CH1);
            PinLossdB_OHC4Cmpnst(nCH) = PindB_CmprsHlthVal_Inv - HL0_PinCochleadB(nFag);
        end
        CompressionHealth = interp1(PinLossdB_OHC4Cmpnst,CmprsHlthList, PinLossdB_OHC(nFag)); % �ł��߂����̂�T��-- �␳�����l
        if isnan(CompressionHealth) == 1, CompressionHealth = 0; end   % NaN�ɂȂ�����0�Ƃ��Ă��܂��B
        PindB_OHCreduction      =  GCFBv231_AsymFuncInOut_InvIOfunc(GCparam,GCresp,Fr1query,CompressionHealth,HL0_IOfuncdB_CH1);
        PinLossdB_OHC(nFag)   = PindB_OHCreduction - HL0_PinCochleadB(nFag);   % HLossdB�͐��̐�
        PinLossdB_IHC(nFag)    = GCparam.HLoss.HearingLeveldB(nFag) - PinLossdB_OHC(nFag);  % 0�ȉ��ł�-0.3dB ���x�̂��ꂠ��B��������Ă����܂�Ȃ�
        
        disp(['Compenstated GCparam.HLoss.CompressionHealth ( ' int2str(Fr1query) ' Hz ) : '  ...
            num2str(GCparam.HLoss.CompressionHealth_InitVal(nFag)) ' --> ' num2str(CompressionHealth) ]);
    end
    
    % ���ꂪ0�ɂȂ�Ȃ����Ƃ͂Ȃ����Adebug�p�ɒu���Ă���
    ErrorOHCIHC = GCparam.HLoss.HearingLeveldB(nFag) -  (PinLossdB_IHC(nFag) + PinLossdB_OHC(nFag));
    if  abs(ErrorOHCIHC) > eps*100 
       disp([ErrorOHCIHC, GCparam.HLoss.HearingLeveldB(nFag), PinLossdB_OHC(nFag),  PinLossdB_IHC(nFag)])
       if  strncmp(GCparam.HLoss.Type,'NH',2) == 0 % 'NH'�̎�����error���o���Ȃ��悤�ɁB
            error('Error in HL_total = HL_OHC + HL_IHC');
        end
    end
    
    GCparam.HLoss.CompressionHealth(nFag) = CompressionHealth; % �ŏI�l������
    %�@�S�̂�gain control�@--- AsymFunction�̍ő�l����v�Z
    HLval_PinCochleadB(nFag) = HL2PinCochlea(Fr1query,0)+GCparam.HLoss.HearingLeveldB(nFag);  % cochlear Input Level �ɕϊ��B�@Compensation of MidEar Trans. Func.
    [dummy, HLval_IOfuncdB_CHval] = GCFBv231_AsymFuncInOut(GCparam,GCresp,Fr1query,CompressionHealth,HLval_PinCochleadB(nFag));
    GCparam.HLoss.AFgainCmpnstdB(nFag) = HLval_IOfuncdB_CHval;
    
end

% NHgainCmpnstBiasdB = [3.5, -1.3, -3, -3, -4, -3, -3] %NH��HL0dB�ɍ��킹�邽�߂̕␳�l�B�A�h�z�b�N
NHgainCmpnstBiasdB = [0, 0, 0, 0, 0, 0, 0];  %�␳�l�͖��������ǂ����Ƃ��킩�����B2021/10/8
GCparam.HLoss.AFgainCmpnstdB = GCparam.HLoss.AFgainCmpnstdB + NHgainCmpnstBiasdB;  
GCparam.HLoss.HLval_PinCochleadB = HLval_PinCochleadB; % renamed from HLval_SPLdB  17 Aug 2021
GCparam.HLoss.PinLossdB_OHC        = PinLossdB_OHC;
GCparam.HLoss.PinLossdB_IHC         = PinLossdB_IHC;
GCparam.HLoss.PinLossdB_OHC_Init = PinLossdB_OHC_Init;
% GCparam.HLoss.IOfuncLossdB_IHC    = IOfuncLossdB_IHC;
% Magic number to set the HL0 at outout 0dB

% interporation to GCresp.Fr1 (which is closer to Fp2)
[ERBrateFag] = Freq2ERB(GCparam.HLoss.FaudgramList);
[ERBrateFr1] = Freq2ERB(GCresp.Fr1); % GC channel��
GCparam.HLoss.FB_Fr1 = GCresp.Fr1;
GCparam.HLoss.FB_HearingLeveldB     = interp1(ERBrateFag,GCparam.HLoss.HearingLeveldB, ERBrateFr1,'linear','extrap');
GCparam.HLoss.FB_HLval_PinCochleadB  = interp1(ERBrateFag,GCparam.HLoss.HLval_PinCochleadB, ERBrateFr1,'linear','extrap');
GCparam.HLoss.FB_PinLossdB_IHC        = interp1(ERBrateFag,GCparam.HLoss.PinLossdB_IHC, ERBrateFr1,'linear','extrap');
GCparam.HLoss.FB_PinLossdB_OHC       = interp1(ERBrateFag,GCparam.HLoss.PinLossdB_OHC, ERBrateFr1,'linear','extrap');
GCparam.HLoss.FB_CompressionHealth = min(max(interp1(ERBrateFag,GCparam.HLoss.CompressionHealth, ERBrateFr1,'linear','extrap'), 0), 1) ;    % 0<= CmprsHlth <= 1;
GCparam.HLoss.FB_AFgainCmpnstdB     = interp1(ERBrateFag,GCparam.HLoss.AFgainCmpnstdB, ERBrateFr1,'linear','extrap');

%% %%%%%%%%%%%
%  Debug�p�@plot
%%%%%%%%%%%%%
%SwPlot = 1;
SwPlot = 0;
if SwPlot == 1
    close all
    % �Ȃ��AGCparam.HLoss.FB_PinLossdB_IHC��GCparam.HLoss.FB_PinLossdB_IHC_GainReduct�������H
    % �Ȃ��A�Q�𕪂������s���B�@�@23 Jan 2021
    % plot(ERBrateFr1,GCparam.HLoss.FB_PinLossdB_IHC,'--' ,ERBrateFr1, GCparam.HLoss.FB_PinLossdB_IHC_GainReduct,'-.', ...
    %       ERBrateFr1, GCparam.HLoss.FB_PinLossdB_OHC  , ERBrateFr1,GCparam.HLoss.FB_PinLossdB_OHC_GainReduct);
    plot(ERBrateFr1,GCparam.HLoss.FB_PinLossdB_IHC,'--' , ...
        ERBrateFr1, GCparam.HLoss.FB_PinLossdB_OHC );
    xlabel('ERB_N number ');
    ylabel('Gain Reduction (dB)');
    legend('IHC_GainReduct','OHC_GainReduct','Location','NorthWest');
    text(3,-2,num2str(GCparam.HLoss.CompressionHealth))
    
    HLcomposition =     [GCparam.HLoss.HearingLeveldB; GCparam.HLoss.PinLossdB_IHC; GCparam.HLoss.PinLossdB_OHC];
    % �ȉ��̒l���O�ł��邱�Ƃ��K�{  --- ���Ȃ炸�Ȃ��Ă���C�����邪�A�A�A
    DiffHL = GCparam.HLoss.HearingLeveldB - (  GCparam.HLoss.PinLossdB_IHC+GCparam.HLoss.PinLossdB_OHC);
    if abs(DiffHL) >  100*eps
        error('Something wrong here');
    end
    % GCparam.HLoss.PinLossdB_IHC_GainReduct+GCparam.HLoss.PinLossdB_OHC_GainReduct
end

return;
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   �֐�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% %%%%%%%%%%%%%%%%%%%%
%    SetHearingLoss
%%%%%%%%%%%%%%%%%%%%%%%

function GCparam = SetHearingLoss(GCparam)

GCparam.HLoss.FaudgramList = [125, 250, 500, 1000, 2000, 4000, 8000];
LenFag = length(GCparam.HLoss.FaudgramList);

if isfield(GCparam.HLoss,'Type')==0, GCparam.HLoss.Type=''; end
if length(GCparam.HLoss.Type) < 1 || strncmp(GCparam.HLoss.Type,'NH',2) == 1
    GCparam.HLoss.Type = 'NH_NormalHearing';  %%
    GCparam.HLoss.HearingLeveldB       = zeros(1,LenFag);
    GCparam.HLoss.PinLossdB_OHC       = zeros(1,LenFag);
    GCparam.HLoss.PinLossdB_IHC        = zeros(1,LenFag);
    GCparam.HLoss.IOfuncLossdB_IHC   = zeros(1,LenFag);
    if isfield(GCparam.HLoss,'CompressionHealth') == 0  % �O�ŗ^�����Ă��Ȃ�������1�ɂ���
        GCparam.HLoss.CompressionHealth = ones(1,LenFag);
    end
    GCparam.HLoss.FB_PinLossdB_OHC      = zeros(GCparam.NumCh,1);
    GCparam.HLoss.FB_PinLossdB_IHC       = zeros(GCparam.NumCh,1);
    GCparam.HLoss.FB_IOfuncLossdB_IHC  = zeros(GCparam.NumCh,1);
    GCparam.HLoss.FB_CompressionHealth = ones(GCparam.NumCh,1);
    
elseif strncmp(GCparam.HLoss.Type,'HL',2) == 1 % HL
    if isfield(GCparam.HLoss, 'CompressionHealth')  == 0
        GCparam.HLoss.CompressionHealth = 0.5*ones(1,LenFag); % default 50%
    end;
    
    NumHL = str2num(GCparam.HLoss.Type(3:min(4,end)));   %HL+2���̏ꍇ (���ݑΉ�)
    if length(NumHL) < 1, NumHL = str2num(GCparam.HLoss.Type(3)); end   %HL+1���̏ꍇ
    GCparam.HLoss.SwType = NumHL;  % 'HL0','HL1','HL2', ...'HL7'... 'HL10', 'HL11' ....
    
    %    See HIsimFastGC_InitParamHI.m for the source --  �ԍ�����v������
    %   9  ��   manual set  �����́A����� extention���l���A 0 �Ԃ�
    %     ParamHI.AudiogramNum : audiogram select
    %                 1.example 1
    %                 2.����2002 80yr
    %                 3.ISO7029 70yr �j
    %                 4.ISO7029 70yr ��
    %                 5.ISO7029 60yr �j
    %                 6.ISO7029 60yr ��
    %                 7.���d����(�悭�킩��I�[�W�I�O����p.47)
    %                 8.�������(�悭�킩��I�[�W�I�O����p.63)
    %                 9.�蓮���́@manual input�@ --> 0�Ԃ�
    %
    
    if GCparam.HLoss.SwType == 0
        GCparam.HLoss.Type='HLval_ManualSet';
        %�����ł́Adefault�l����ꂸ�ɁA�O������̐ݒ肪�����ꍇ�ɂ�error
        LenHL = length(GCparam.HLoss.HearingLeveldB);
        if  LenHL < length(GCparam.HLoss.FaudgramList),
            error('Set GCparam.HLoss.HearingLeveldB at FaudgramList in advance.');
        end
        if (mean(GCparam.HLoss.HearingLeveldB) < 10*eps)  % �ݒ肪NH���ǂ���. warning�����o��
            warning('mean(GCparam.HLoss.HearingLeveldB) nearly equal 0 --- NH?')
        end
    elseif GCparam.HLoss.SwType == 1   % Preset examples
        GCparam.HLoss.Type='HL1_Example';
        %%%                                             % [125, 250,  500, 1000, 2000, 4000, 8000];
        GCparam.HLoss.HearingLeveldB = [ 10  4 10 13 48 58 79];
    elseif GCparam.HLoss.SwType == 2    % Preset examples
        GCparam.HLoss.Type='HL2_Tsuiki2002_80yr';
        %%%                                             % [125, 250,  500, 1000, 2000, 4000, 8000];
        GCparam.HLoss.HearingLeveldB = [ 23.5, 24.3, 26.8,  27.9,  32.9,  48.3,  68.5];
    elseif GCparam.HLoss.SwType == 3
        GCparam.HLoss.Type='HL3_ISO7029_70yr_male';
        GCparam.HLoss.HearingLeveldB = [ 8  8  9 10 19 43 59];
    elseif GCparam.HLoss.SwType == 4
        GCparam.HLoss.Type='HL4_ISO7029_70yr_female';
        GCparam.HLoss.HearingLeveldB = [ 8  8  9 10 16 24 41];
    elseif GCparam.HLoss.SwType == 5
        GCparam.HLoss.Type='HL5_ISO7029_60yr_male';
        GCparam.HLoss.HearingLeveldB = [ 5  5  6  7 12 28 39];
    elseif GCparam.HLoss.SwType == 6
        GCparam.HLoss.Type='HL6_ISO7029_60yr_female';
        GCparam.HLoss.HearingLeveldB = [ 5  5  6  7 11 16 26];
    elseif GCparam.HLoss.SwType == 7
        GCparam.HLoss.Type='HL7_Example_Otosclerosis';
        GCparam.HLoss.HearingLeveldB = [  50 55 50 50 40 25 20 ]; % otosclerosis ���d����(�悭�킩��I�[�W�I�O����p.47)
    elseif GCparam.HLoss.SwType == 8
        GCparam.HLoss.Type='HL8_Example_NoiseInduced';
        GCparam.HLoss.HearingLeveldB = [  15 10 15 10 10 40 20 ]; % otosclerosis %�������(�悭�킩��I�[�W�I�O����p.63)
    else
        error('Specify GCparam.HLoss.Type (HL0, HL1, HL2, ....) properly.');
    end;
else
    error('Specify GCparam.HLoss.Type (NH, HL0, HL1, HL2, ....) properly.');
end

if length(GCparam.HLoss.CompressionHealth) == 1
    GCparam.HLoss.CompressionHealth = GCparam.HLoss.CompressionHealth*ones(1,LenFag);
end

return;
end



%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trash
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% �ȉ��̕����́Aad hoc�ɕt���������Ƃ���B������Ƌ^��B 25 Aug 2021
%
%     % dcGCFB�� �o��0dB�܂łɌ��炷���߂́AIHC��gain reduction�̌v�Z
%     % PinLossdB_IHC_GainReduct�́A�d�v�ȃp�����[�^�BPinLossdB_IHC�Ƃ͈قȂ�AAbsThrsh��ʂ�悤�ɒ����������
%     % �@�@�@[~, nHL_IHC_GR] = min(abs(GCparam.HLoss.HearingLeveldB(nFag) - GaindB_MidEar(nFag) - InputdB));
%     [~, nHL_IHC_GR] = min(abs(GCparam.HLoss.HearingLeveldB(nFag) + HLval_PinCochleadB(nFag) - TableInputdB));
%     %    PinLossdB_IHC_GainReduct(nFag) = OutputdB(nFag,nHL_IHC_GR,nCmprsHlthMatch2);
%
%     % ���ꂪ�ACompressionHealth�ɂ���ĈႤ�Ɖ���B
%     % FactCmpnst = 10;   % 1����̍�����10�{�� 4000Hz�͊����BFactCmpnst =15�͂�肷��
%     FactCmpnst = 12;   % �����̌��ʁA���ꂪ�悩�����B  24 Jan 2021
%     PinLossdB_IHC_GainReduct(nFag) = OutputdB(nFag,nHL_IHC_GR,nCmprsHlthMatch2) ...
%         -  FactCmpnst*(1-GCparam.HLoss.CompressionHealth(nFag));
%
%  �������̃����́ATrash�ɁB

% 100 dB�̎��̏o�͂���Gain������ -- MidEar���͕␳���Ȃ��B
% MidEar���͕␳���邽�߂ɂ́A- GaindB_MidEar(:) ����B
%�������AGCFB�̓��͂�ELC�␳�Ŋ�{�I�ɂ�cochlea �������x���ɂȂ��Ă���Ƃ�������B

%     %%% GCparam.HLoss.PinLossdB_OHC_Init     = PinLossdB_OHC_Init;
% GCparam.HLoss.HLval_PinCochleadB           = HLval_PinCochleadB; % renamed from HLval_SPLdB  17 AUg 2021
% % GCparam.HLoss.HLval_SPLdB           = HLval_SPLdB;  % renamed  --- �Ƃ肠�����O���Ă݂�
% % GCparam.HLoss.GaindB_MidEar      = GaindB_MidEar;% renamed  --- �Ƃ肠�����O���Ă݂�
% %%%% GCparam.HLoss.InputdB                 = TableInputdB;
% GCparam.HLoss.PindB_At_AbsThreshold  = PindB_At_AbsThreshold;
% %%% GCparam.HLoss.OutputdB              = OutputdB;
% %%% GCparam.HLoss.OutputdB_For_Normalize ...
% %%%    = OutputdB(:,GCparam.HLoss.NumInputdB_For_Normalize, GCparam.HLoss.NumCompressionHealthOne);
% GCparam.HLoss.PinLossdB_IHC        = PinLossdB_IHC;
% %GCparam.HLoss.PinLossdB_IHC_GainReduct  =  PinLossdB_IHC_GainReduct;  % PinLossdB_IHC�ƈႢFB��Gain��ł̈Ⴂ������
% %GCparam.HLoss.PinLossdB_IHC_GainReduct_FactCmpnst  = FactCmpnst;
% GCparam.HLoss.PinLossdB_OHC      = PinLossdB_OHC;
% % GCparam.HLoss.PinLossdB_OHC_GainReduct  = PinLossdB_OHC_GainReduct;��̃p�����[�^�Ȃ̂ŁA�����B

%GCparam.HLoss.FB_PinLossdB_IHC_GainReduct = interp1(ERBrateFag,GCparam.HLoss.PinLossdB_IHC_GainReduct, ERBrateFr1,'linear','extrap');
% GCparam.HLoss.FB_PinLossdB_OHC_GainReduct = interp1(ERBrateFag,GCparam.HLoss.PinLossdB_OHC_GainReduct, ERBrateFr1,'linear','extrap');
% GCparam.HLoss.FB_OutputdB_For_Normalize = interp1(ERBrateFag,GCparam.HLoss.OutputdB_For_Normalize, ERBrateFr1,'linear','extrap');

%GCparam.HLoss.AFgainCmpnstdB =    [  21.20   15.55   12.75   12.82   10.32   15.95   14.79];  % magic number  17 Aug 2021

% compensation dB for fine tuning
% GCparam.HLoss.AFgainCmpnstdB_FineTune = [0 0 0 0 0 0 0]; %No compensation is bettter. 29 Aug 2021
% NG GCparam.HLoss.AFgainCmpnstdB_FineTune = [ 4.0754    0.3947   -3.1380   -3.2595   -4.0650   -3.3516   -3.2788];
% GCparam.HLoss.FB_AFgainCmpnstdB_FineTune = interp1(ERBrateFag,GCparam.HLoss.AFgainCmpnstdB_FineTune, ERBrateFr1,'linear','extrap');

% 2021/10/7 --> 2021/10/8
% ���̒l�́AGCparam.HLoss.AFgainCmpnstdB��NH�̏ꍇ�̏o�͂���A���ߑł��ŏ����o���Ă��܂��B2021/10/7
% AFgainCmpnstdB_NH = [45.9179   44.9092   45.0596   45.2239   43.6439   48.5413   47.1842]; %NH�ł̒l
%  GCparam.HLoss.NHgainCmpnstdB= GCparam.HLoss.NHgainCmpnstBiasdB+AFgainCmpnstdB_NH; %HL0dB�ɍ��킹�邽�߁A�␳�B
% GCparam.HLoss.FB_NHgainCmpnstdB     = interp1(ERBrateFag,GCparam.HLoss.NHgainCmpnstdB, ERBrateFr1,'linear','extrap');
% --> ���ǎg��Ȃ����ƂɁB2021/10/8
