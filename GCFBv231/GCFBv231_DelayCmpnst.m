%
%       Delay compensation gc filter working with GCFBv230
%       IRINO, T.
%       Created:  11 Feb 2021 from CmpnstERBfilt (in ERBtool)
%       Modified:  11 Feb 2021
%       Modified:  13 Feb 2021 % NumCmpnst �C�� (+1��������)
%       Modified:  27 Feb 2021 % Frame base�ł�Sample base�ł��g����悤�ɁB
%
% Note:
%       sample-by-sample���ƁACmpnstERBFilt.m�ōs���Ă����B
%       frame-base����frame�̃T���v�����O���g�����Ⴄ�̂Ő�p�ɊJ��
%       GCFB�����S�̂̎��Ԓx������ā@pulse�n��Ƃ̎��Ԓx���␳
%
%
function [GCcmpnst, DCparam]  = GCFBv230_DelayCmpnst(GCval,GCparam,DCparam)

disp('*** GC filter delay compensation ***');
if isfield(DCparam,'fs') == 0,
    error('Specify sampling frequency (fs) of  input GCval. ');
    %  ����ŁAFrame base�ł�Sample-base�ł��Ή��\
end;

% Delay �̃p�����[�^�Ftuning�ケ�̒l�ɂ����B�ʏ�͕ύX���Ȃ������ǂ����A�ꉞ�O��������\�ɁB
if nargin <= 2 || isfield(DCparam,'TdelayFilt1kHz') == 0  % default�l�������B
    DCparam.TdelayFilt1kHz =0.002;  % default 2 ms @ 1 kHz
end
if isfield(DCparam,'TdelayFB') == 0  % default�l�������B
    DCparam.TdelayFB    = 0; %  GCFB�S�̂�delay:  default 0 ms
    %%% NG    DCparam.TdelayFB    = 0.002; %  GCFB�S�̂�delay:  default 2 ms
    %%% �ŏ��������Ă������AGCFB�̒��ŕ��Ă���Ȃ�s�v�B
end;
if DCparam.TdelayFilt1kHz < 0 ||  DCparam.TdelayFB< 0
    error('Negative delay compensation is not allowed.');
end

[NumCh, LenVal] = size(GCval);
GCcmpnst = zeros(NumCh,LenVal);
for nch =1:NumCh
    NumCmpnst = fix((DCparam.TdelayFilt1kHz*1000/GCparam.Fr1(nch) + DCparam.TdelayFB)*DCparam.fs);
    
    if rem(nch,50) == 0 | nch == NumCh | nch == 1
        fprintf('Compensating delay:  ch #%d / #%d.  [Delay = %5.2f (ms)] \n', ...
            nch, NumCh, NumCmpnst/DCparam.fs*1000);
    end
    if abs(NumCmpnst) > LenVal
        error('Sampling point for Compensation is greater than the signal length.');
    end
     
    GCcmpnst(nch,:) = [GCval(nch,(NumCmpnst+1):LenVal), zeros(1,NumCmpnst)];
    DCparam.NumCmpnst(nch) = NumCmpnst;
end

return

%     NumCmpnst =  fix(NumDelayFilt1kHz * 1000/GCparam.Fr1(nch)); % GCFBv230_SetParam��GCparam.Fr1��set����Ă���

