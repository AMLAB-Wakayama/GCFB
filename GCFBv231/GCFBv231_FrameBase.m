%
%       Frame-based processing of HP-AF of dcGCFB
%       Toshio IRINO
%       Created:   13 May 2020 (Extracted from GCFBv211.m)
%       Modified:   13 May 2020 (Extracted from GCFBv211.m)
%       Modified:  14 May 2020  (for checking processing speed)
%       Modified:  16 May 2020  (v220, introduction of frame-base processing)
%       Modified:  24 May 2020  (introduction of cGCfxFrame narrow filter)
%       Modified:  26 Jul 2020  (v230, modified some comments)
%       Modified:  27 Feb 2021  (v230, fucntion)
%       Modified:  13 Aug 2021 (v230, 3rd output argument pGCframe -->  scGCframe)
%       Modified:  15 Aug 2021 (v230,AmpNormAFG using GCparam.IOfuncPinEqPoutdB)
%       Modified:  17 Aug 2021  (v230, output modified , GCresp.LvldBframe, GCresp.pGCframe, GCresp.scGCframe, )
%       Modified:  28 Aug 2021  v231 no change in function
%       Modified:   3 Sep  2021  v231 some tests
%       Modified:  17 Sep  2021  renamed NumFrame --> LenFrame,  LenFrame--> LenWin  as  defined in SetFrame4TimeSequence
%       
%
% function [dcGCframe, GCresp] = GCFBv230_FrameBase(pGCsmpl, scGCsmpl, GCparam, GCresp)
%      INPUT:  pGCsmpl:    passive GC sample
%                   scGCsmpl:  static cGC sample
%                   GCparam: 
%                   GCresp:
%
%      OUTPUT: 
%              dcGCframe:  frame level output of dcGC-FB
%              GCresp : 
%              pGCframe:  frame level output of pGC-FB
%              scGCframe:  frame level output of static compressive GC-FB
%
% Frame-based processing
%     See CalSmoothSpec.m / SetFrame4TimeSequence
%
function [dcGCframe, GCresp] = GCFBv231_FrameBase(pGCsmpl, scGCsmpl, GCparam, GCresp)

ExpDecayFrame = GCparam.LvlEst.ExpDecayVal.^(GCparam.DynHPAF.LenShift);
[NumCh, LenSnd] = size(pGCsmpl);
disp('--- Frame base processing ---');
Tstart = clock;

NfrqRsl = 1024*2;  % normalization�p�Ɏ��g���������Z�o���Ă���
c2val_CmprsHlth = GCparam.HLoss.FB_CompressionHealth.* GCparam.LvlEst.c2;
scGCresp = CmprsGCFrsp(GCparam.Fr1,GCparam.fs,GCparam.n,GCresp.b1val,GCresp.c1val, ...
                                        GCparam.LvlEst.frat,GCparam.LvlEst.b2,c2val_CmprsHlth,NfrqRsl);

    
for nch = 1:NumCh
    %%%%%%%%%
    % signal path
    %%%%%%%%%
    % pGC only
    [pGCframeMtrx, nSmplPt] = SetFrame4TimeSequence(...
        pGCsmpl(nch,:),GCparam.DynHPAF.LenFrame,GCparam.DynHPAF.LenShift);
    [LenWin, LenFrame] = size(pGCframeMtrx);
    % cGC level estimation filter -- This BW is narrower than that of pGC.
    % roughly at Pgc == 50
     [scGCframeMtrx, nSmplPt] = SetFrame4TimeSequence(...
        scGCsmpl(nch,:),GCparam.DynHPAF.LenFrame,GCparam.DynHPAF.LenShift);
    % [LenWin, LenFrame] = size(scGCframeMtrx);
    if nch == 1,
        pGCframe         = zeros(NumCh,LenFrame);
        LvldBframe      = zeros(NumCh,LenFrame);
        fratFrame         = zeros(NumCh,LenFrame);
        AsymFuncGain = zeros(NumCh,LenFrame);
        dcGCframe         = zeros(NumCh,LenFrame);
    end;
    
    pGCframe(nch,1:LenFrame) = sqrt(GCparam.DynHPAF.ValWin(:)'*(pGCframeMtrx.^2));  % weighted mean
    scGCframe(nch,1:LenFrame) = sqrt(GCparam.DynHPAF.ValWin(:)'*(scGCframeMtrx.^2));  % weighted mean
   
    %%%%%%%%%
    % level estimation path     %  Level estimation from HIsimFastGC.m  -->  modified
    %%%%%%%%%
    [LvlLin1FrameMtrx, nSmplPt] = SetFrame4TimeSequence(...
        pGCsmpl(GCparam.LvlEst.NchLvlEst(nch),:),GCparam.DynHPAF.LenFrame,GCparam.DynHPAF.LenShift);
    LvlLin1Frame = sqrt(GCparam.DynHPAF.ValWin(:)'*(LvlLin1FrameMtrx.^2));  % weighted mean
    
    [ LvlLin2FrameMtrx, nSmplPt] = SetFrame4TimeSequence(...
        scGCsmpl(GCparam.LvlEst.NchLvlEst(nch),:),GCparam.DynHPAF.LenFrame,GCparam.DynHPAF.LenShift);
    LvlLin2Frame = sqrt(GCparam.DynHPAF.ValWin(:)'*(LvlLin2FrameMtrx.^2));
    
    for nFrame = 1:LenFrame-1  % Compensation of decay constant, GCparam.LvlEst.ExpDecayVal not in HIsimFastGC.m 
        LvlLin1Frame(nFrame+1) = max(LvlLin1Frame(nFrame+1),  LvlLin1Frame(nFrame)*ExpDecayFrame);
        LvlLin2Frame(nFrame+1) = max(LvlLin2Frame(nFrame+1),  LvlLin2Frame(nFrame)*ExpDecayFrame);
    end;
    
    LvlLinTtlFrame = GCparam.LvlEst.Weight * ...
        GCparam.LvlEst.LvlLinRef*(LvlLin1Frame/GCparam.LvlEst.LvlLinRef).^GCparam.LvlEst.Pwr(1) ...
        + (1 - GCparam.LvlEst.Weight) * ...
        GCparam.LvlEst.LvlLinRef*(LvlLin2Frame/GCparam.LvlEst.LvlLinRef).^GCparam.LvlEst.Pwr(2);
    
    % level monitored 4 Sep 2021�@�@--- ���ɕςł͂Ȃ������B

    CmpnstHalfWaveRectify = -3;      % Cmpensation of  a halfwave rectification which was used in "sample-by-sample."
    LvldBframe(nch,1:LenFrame) = 20*log10( max(LvlLinTtlFrame,GCparam.LvlEst.LvlLinMinLim) ) ...
        + GCparam.LvlEst.RMStoSPLdB + CmpnstHalfWaveRectify;     % GCparam.LvlEst.RMStoSPLdB == 30 dB Meddis HC level
    
    [AFoutdB, IOfuncdB, GCparam] = GCFBv231_AsymFuncInOut(GCparam,GCresp, GCparam.Fr1(nch), ...
                       GCparam.HLoss.FB_CompressionHealth(nch), LvldBframe(nch,:));
    AsymFuncGain(nch,1:LenFrame)  = 10.^((AFoutdB)/20);  % default
         
    scGCframe1 = scGCresp.NormFctFp2(nch) * scGCframe(nch,:); 
    % normalization:  scGCframe��peak�����g���Ɋւ�炸0dB�ƂȂ�悤�� 5 Sep 21
    % ���g�������ŁAFp2��max�ƂȂ�i���̂悤�Ȏ��g����Fp2)�B����peak�����ɂ���BFr1�ƈقȂ邪�A�߂��̂ł悵�Ƃ���B
    % GammaChirp.m�̂����𓥏P�@26 Aug 21
    %  plot(20*log10(scGCresp.NormFctFp2)) --  -3 dB ~ + 1 dB�@���������␳�ʂł͂Ȃ��B
    
    dcGCframe(nch,1:LenFrame) = AsymFuncGain(nch,:) .*scGCframe1;
    
    if nch == 1 || rem(nch,20)==0
        disp(['Frame-based HP-AF: ch #' num2str(nch) ' / #' num2str(NumCh) ...
            '.    elapsed time = ' num2str(fix(etime(clock,Tstart)*10)/10) ' (sec)']);
        
       %% DEBUG_MODE
       % Level estimation�Ɋւ��Ă͖��Ȃ��B�[�[�@�m�F�@28 Aug 2021
       % [nch mean(LvldBframe(nch,:)), max(LvldBframe(nch,:))]
       % plot( LvldBframe(nch,:) )
       %
    end
    
end

% Data �����n���p
GCresp.LvldBframe = LvldBframe; % Level���͂����ɓ����Ă���B
GCresp.pGCframe   = pGCframe;   % pGCframe
GCresp.scGCframe  = scGCframe;  % scGCframe
GCresp.fratFrame   = fratFrame;
GCresp.AsymFuncGain = AsymFuncGain;

return;

%% %%%%%%%%%%
% Trash
%%%%%%%%%%%%

% Same tests 3 Sep 21
% 1)    NG: LvldBframe(nch,:) = LvldBframe(nch,:) -10; %%
%        ���炷�ƁAHL2�ł��������͂������ƂɂȂ�BNH�́A���悭�Ȃ邪�A����ł�5dB�̉��P�ɂ����Ȃ��B-- �g��Ȃ����Ɓ@ 3 Sep21
% 2)    NG : CmpnstHalfWaveRectify = 0;   % ignore Halfwave rect  NH�̂Ƃ��̂��ꂪ�傫���Ȃ�@�@3 Sep 21

    
    % AmpNormAFG = 1/exp(c2val*pi/2); <-- exp(2.2*pi/2)=31 (maximum amlitude)
    % AmpNormAFG = 1; % magic number  ErrdB = -7.82 dB 
    %AmpNormAFG = 1.3; % magic number:   pulse train  ErrdB = -8.96 dB 
    % AmpNormAFG = 1.4; % magic number:    pulse train ErrdB =  -8.67 dB
    % AmpNormAFG = 1.5; % magic number:  pulse train ErrdB =  -8.07 dB
    % AmpNormAFG = 1.28; % magic number  pulse train  ErrdB = -8.99 dB peak matched
    %%% NG -- AmpNormAFG = 1.3;   %   pulse train ErrdB = -8.6851 ���ꂪ�߂����@�@noise case:�@ErrdB = -5.4127
    %AsymFuncGain = min(AsymFuncGain,10); % Limiting maximum is not necessary.   exp(2.2*pi/2)=31
    
    
    %  GCparam.HLoss.FB_CompressionHealth(nch)  is introduced in c2val  
%
%       for check:  24 May 20
%       if 0 % nch == 50 || nch ==100
%         disp('nch = 50 or 100');
%         vvv =  [nch 20*log10([max(LvlLin1Frame)  max(LvlLin2Frame) max(LvlLinTtlFrame)])+30, ...
%             mean(LvldBframe(nch,:))]
%         subplot(3,1,1)
%         plot(20*log10(mean(pGCframe,2))+30)
%         max_pGCframe = max(20*log10(mean(pGCframe,2))+30)
%         grid on;
%         subplot(3,1,2)
%         plot(mean(LvldBframe,2))
%         max_LvldBframe = max(mean(LvldBframe,2))
%         grid on;
%     end;
%     

%     %%%%%%%%%
%     % Gain calculation from the idea in HIsimFastGC.m
%     % frat --> Gain   50dB RefdB
%     %%%%%%%%%

% % %     fratFrame(nch,1:LenFrame) = GCresp.frat0Pc(nch) + ...
% % %                         GCresp.frat1val(nch)*(LvldBframe(nch,:) - GCresp.PcHPAF(nch));

%     %  forigin = GCresp.Fr1(nch); % filter center frequency -- closer than Fp1
%     Fp1 = GCresp.Fp1(nch);  % this is from the original definition.  What we wish to know is the gain.
%     Fr2  = fratFrame(nch,:) * Fp1; % NH
%     [dummy ERBwFr2] = Freq2ERB(Fr2);
%     c2val_CH = GCresp.c2val.*GCparam.HLoss.FB_CompressionHealth; % HI Compression health
%     
%     AmpNormAFG_1  = 1;   % it is the most simple.    
%     AmpNormAFG_pi2 = exp(c2val_CH(nch)*(pi/2)); % �␳��A����Ȃ�Ɉ�v����悤�ɂȂ����B�@�i�ŏ���OK when CH > 0.25, But not good when CH<=0.25�j
%     AmpNormAFG =    AmpNormAFG_pi2;  % 15 Aug 2021���_�ŁA���ꂪ�ǂ� OK
%     
%     % AmpNormAFG = AmpNormAFG_1;  %%%
%     %     if 0 % ---  ����́A�ŏI�I�ɂ͂��܂�悭�Ȃ����ʂɁB16 Aug 2021
%     %    17 Aug 21�ɂ���Ă݂����A��͂肾��
%     %    100dB�ň�v����悤�ɐݒ�B�@GCparam.HLoss.InputdB_For_Normalize��100 dB
%     %     fratNorm = GCresp.frat0Pc(nch) + GCresp.frat1val(nch).*( GCparam.HLoss.InputdB_For_Normalize - GCresp.PcHPAF(nch));
%     %     Fr2norm = fratNorm*Fp1;
%     %     [dummy ERBwFr2norm] = Freq2ERB(Fr2norm);
%     %     AmpNormAFG_IOEq = exp(c2val_CH(nch)*atan2( Fr2norm - Fp1, GCresp.b2val(nch)*ERBwFr2norm));
%     %     AmpNormAFG =    AmpNormAFG_IOEq;
%     %
%     AsymFuncGain(nch,1:LenFrame) = AmpNormAFG*exp(c2val_CH(nch)*atan2(Fp1 - Fr2,GCresp.b2val(nch)*ERBwFr2));  
% 
%     % dcGCframe(nch,1:LenFrame) = AsymFuncGain(nch,:).*pGCframe(nch,:); % NG  The bandwidth is too wide.
%     dcGCframe(nch,1:LenFrame) = AsymFuncGain(nch,:).*scGCframe(nch,:); % using  fixed cGC filter output. narrower BW
    

% 4 Sep 2021 --- ����Ă݂����A�悭�킩��Ȃ��B
%     if nch == 73
%         figure(30)
%         plot(1:LenFrame, 20*log10(LvlLinTtlFrame), 1:LenFrame, 20*log10(LvlLin1Frame),'-.', 1:LenFrame, 20*log10(LvlLin2Frame),'--')
%         hold on
%         pause(0.1)
%     end
    

%% %%%%%%%%%%%%
% Trial & Error 7 Oct 21
%%%%%%
% 7 Oct 21
% ���͑���HL_IHC���|����-- NG --- �P�ɉ����ɍs������
% GainFactor_HL_IHC= 10^(-GCparam.HLoss.FB_PinLossdB_IHC(nch)/20);
% pGCframe(nch,1:LenFrame) = GainFactor_HL_IHC*pGCframe(nch,1:LenFrame);
% scGCframe(nch,1:LenFrame) = GainFactor_HL_IHC*scGCframe(nch,1:LenFrame);

 % GCresp.PcHPAF = GCresp.PcHPAF - GCparam.HLoss.FB_PinLossdB_IHC;  NG
 % PindB�����炷�̂Ɠ������ʁB
 

 % �߂����Ⴄ
 % �܂����������`�ŁA�V�t�g�������̂��ق����B
%       [AFoutdB1, IOfuncdB1, GCparam] = GCFBv231_AsymFuncInOut(GCparam,GCresp, GCparam.Fr1(nch), ...
%                                        GCparam.HLoss.FB_CompressionHealth(nch), LvldBframe(nch,:)+ GCparam.HLoss.FB_PinLossdB_IHC(nch));
%    CmpnstdB_HL_IHC = IOfuncdB-IOfuncdB1;
                                    
%    AsymFuncGain(nch,1:LenFrame)  = 10.^((AFoutdB+CmpnstdB_HL_IHC)/20);
    
%     [AFoutdB_HL_IHC, IOfuncdB_HL_IHC, GCparam] = GCFBv231_AsymFuncInOut(GCparam,GCresp, GCparam.Fr1(nch), ...
%                         GCparam.HLoss.FB_CompressionHealth(nch), LvldBframe(nch,:) + GCparam.HLoss.FB_PinLossdB_IHC(nch));
% %     [AFoutdB_HL_IHC, IOfuncdB_HL_IHC, GCparam] = GCFBv231_AsymFuncInOut(GCparam,GCresp, GCparam.Fr1(nch), ...
% %                         GCparam.HLoss.FB_CompressionHealth(nch), LvldBframe(nch,:) + 10);
% %     % CmpnstdB_HL_IHC = IOfuncdB-IOfuncdB_HL_IHC;  % NG   == AFoutdB-AFoutdB_HL_IHC;  % NG
%     AFoutdB = AFoutdB_HL_IHC;


    % AsymFuncGain(nch,1:LenFrame)  = 10.^((AFoutdB)/20);  
     %�S�R���߁@AsymFuncGain(nch,1:LenFrame)  = 10.^((AFoutdB1)/20); % NG �͈͂����肳��Ă��܂��Ă���Bwhy�H
    % AFoutdB = zeros(size(AFoutdB));      % 0 dB�ɋ����I�ɂ��Ă݂��B�B�B
    %     AsymFuncGain(nch,1:LenFrame)  = 10.^((AFoutdB-GCparam.HLoss.FB_PinLossdB_IHC(nch))/20);
    %     AsymFuncGain(nch,1:LenFrame)  = 10.^((AFoutdB1-GCparam.HLoss.FB_PinLossdB_IHC(nch))/20); % NG

    %    AsymFuncGain(nch,1:LenFrame)  = 10.^((AFoutdB+IOfuncdB-IOfuncdB1)/20);   NG
    % AsymFuncGain(nch,1:LenFrame)  = 10.^((AFoutdB+IOfuncdB-IOfuncdB1+LvldBframe(nch,:))/20);   % �S�R����
    % ---
    % 
    
% ���߁BAsymFuncGain(nch,1:LenFrame)  = 10.^((AFoutdB+IOfuncdB-IOfuncdB1)/20);
% �Ɠ����ŁA����
%     ModSPLdB = [-50:10:110];
%     [OutdBTbl, IOfuncdBTbl] = GCFBv231_AsymFuncInOut(GCparam,GCresp, GCparam.Fr1(nch), ...
%                        GCparam.HLoss.FB_CompressionHealth(nch), ModSPLdB);
%     [OutdBTbl2, IOfuncdBTbl2] = GCFBv231_AsymFuncInOut(GCparam,GCresp, GCparam.Fr1(nch), ...
%                        GCparam.HLoss.FB_CompressionHealth(nch), ModSPLdB+GCparam.HLoss.FB_PinLossdB_IHC(nch));
%      ModIOfuncdBTbl =    IOfuncdBTbl-IOfuncdBTbl2;                
%     [CmpnstLvldBframe] = interp1(ModSPLdB, ModIOfuncdBTbl, LvldBframe(nch,:));
%     % mean(CmpnstLvldBframe)
%     %      AsymFuncGain(nch,1:LenFrame)  = 10.^((AFoutdB+CmpnstLvldBframe)/20);  % default
%
%        [AFoutdB1, IOfuncdB1, GCparam] = GCFBv231_AsymFuncInOut(GCparam,GCresp, GCparam.Fr1(nch), ...
%                         GCparam.HLoss.FB_CompressionHealth(nch), LvldBframe(nch,:)+beta*GCparam.HLoss.FB_PinLossdB_IHC(nch));
%  IO function�����炷�K�R�͂Ȃ��B

    %����AsymFuncInOut�ŋ��߂Ă��܂��B
    % LvldB_HL_IHC = LvldBframe(nch,:) + GCparam.HLoss.FB_PinLossdB_IHC(nch); �߂��͒ʂ邪�`���Ⴄ�B
    % LvldB_HL_IHC = LvldBframe(nch,:) -�@GCparam.HLoss.FB_PinLossdB_IHC(nch);�@�͂����
    % --> �����ł͂��点�Ȃ�

