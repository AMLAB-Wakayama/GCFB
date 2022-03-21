%
%       Synthesis sound for GCFBv23x
%       IRINO, T.
%       Created:   28 Feb 2021 
%       Modified:  28 Feb 2021 % 
%       Modified:  25 Oct 2021 % introducing MkFilterField2Cochlea
%       Modified:   6  Mar 2022  v232  rename of GCFBv231_func -->  GCFBv23_func 
%
% Note:
%       GCFB��ELC�␳�����ĕ��͂��Ă���ꍇ�A������t�␳����K�v����B
%
%
function [SndSyn]  = GCFBv23_SynthSnd(GCsmpl,GCparam)

disp('*** Synthesis from GCFB 2D-sample ***');
fs = GCparam.fs;
% Inverse compensation of ELC
if strcmp(upper(GCparam.OutMidCrct),'NO') ~= 1
    % ELC���̋t�t�B���^�B���g��������������̕����ǂ��B
    AmpSyn = -15; % AnaSyn��impulse ��������v����悤�Ɍ��߂��B
                             % GCFB�̎��g���͈͂ɂ���ĉe���͂Ȃ��B
    Tdelay = 0.00632; % filter delay  ���Ԓx��̕␳�B �������AELC filter�p�B
    Ndelay = fix(Tdelay*fs);
     InvCmpnOutMid = MkFilterField2Cochlea(GCparam.OutMidCrct,fs,-1); % -1) backward inverse filter 26 Oct 21
    SndMean = mean(GCsmpl);
    SndSyn1 = filter(InvCmpnOutMid,1,SndMean);
    % �U���Ǝ��Ԓx��␳
    SndSyn = AmpSyn*[SndSyn1(Ndelay+1: end), zeros(1,Ndelay)];
else
    % ELC���̏d�ݕt�����Ȃ��ꍇ
    disp('No inverse OutMidCrct (FF / DF / ITU +MidEar / ELC) correction.');
    AmpSyn = -15;  % ��Ɠ����l��OK
    SndSyn =  AmpSyn*mean(GCsmpl);
end

return
