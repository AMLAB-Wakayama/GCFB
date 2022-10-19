%
%   Table of corresponding between HL and SPL
%   Irino T.,
%   Created:  21 Feb 2018  ( ANSI S3.6-1996 standard)
%   Modified:  21 Feb 2018  ( ANSI S3.6-1996 standard)
%   Modified:  23 Feb 2018  Table ��Ɨ��̃t�@�C���Ƃ���
%   Modified:  24 May 2018  ANSI S3.6-2010 standard�̒l�𓱓��B���Ԃ̎��g���̒l���V���ɒǉ�����Ă���B
%   Modified:    6 Jun  2018  ���Ⴂ���C���BNote�ɋL�q
%
% function   [Table] = TableSPLatHL0dB(SwYear)
% INPUT:  SwYear
% OUTPUT:   Table.freq : ���g��
%                   Table.SPLatHL0dB : SPL dB
% ------------------------------------------------------------
% Information:
% ------------------------------------------------------------
%
%  Note: 21 Feb 2018
% ANSI_S3.6-1996�̏��
% http://hearinglosshelp.com/blog/understanding-the-difference-between-sound-pressure-level-spl-and-hearing-level-hl-in-measuring-hearing-loss/
% ANSI_S3.6-2004�̏��
% https://www.researchgate.net/publication/284004608_Audiometric_calibration_Air_conduction
% ANSI_S3.6-2010�̏��F�@2018/5/24. document����BASA�����5�{�܂�standard�𖳗������
%
% Note: 6 May 2018
%       1996���I�[�W�I���[�^����ȊO�̒��Ԃ̎��g������B
%       ���l���A�C���z����TDH Type IEC318 �̏ꍇ�A2010�� �S������
%       SwYear�ŕ�����̂͂ӂ��킵���Ȃ��B--> ����
%        SPLatHL0dB_Table(SwYear) --> SPLatHL0dB_Table
%
%
function  [Table] = SPLatHL0dB_Table

%  ANSI_S3.6-2010 (1996)�̒��Ԃ̎��g�����܂�Table
    %���g������������̂ŁA��΂��L��
    Freq_SPLdBatHL0dB_List = ...
        [125, 45.0; 160, 38.5; 200, 32.5; ...
        250, 27.0; 315, 22.0; 400, 17.0; ...
        500, 13.5; 630, 10.5; 750, 9.0; 800, 8.5;  ...
        1000, 7.5; 1250, 7.5; 1500, 7.5; 1600, 8.0; ...
        2000, 9.0; 2500, 10.5; 3000, 11.5; 3150, 11.5; ...
        4000, 12.0; 5000, 11.0; 6000, 16.0; 6300, 21.0; ...
        8000, 15.5];
    Speech = 20.0; % ANSI_S3.6_2010;
    
    Table.freq = Freq_SPLdBatHL0dB_List(:,1)';
    Table.SPLatHL0dB = Freq_SPLdBatHL0dB_List(:,2)';
    Table.Speech = 20.0;
    Table.Standard = 'ANSI-S3.6_2010';
    Table.Earphone = 'Any supra aural earphone having the characteristics described in clause 9.1.1 or ISO 389-1'; 
            %�C���z���BANSI-S3.6_2010�̋K�i����p.26 Table 5 �̒���a�ɋL�q����Ă���Ƃ���B
    Table.AirficialEar = 'IEC 60318-1';  % �l�H���B����ő��肵�āA�Z���������B

    
% �Q�l 21 Feb 2018�ɏ����������B
% �I�[�W�I���[�^�̑�����g�������Ɋւ��Ă�Table
    %Freq_ANSI_S36_1996_Augiogram     = [125  250  500  750 1000 1500 2000 3000 4000 6000 8000];
    %SPLdBatHL0dB_ANSI_S36_1996_Augiogram     = [45.0 27.0 13.5 9.0 7.5  7.5  9.0  11.5 12.0 16.0 15.5];
                                                    % ANSI_S36_1996�́ARion AA79, AA74�ō̗p����Ă�����̂Ɠ���
    % Table.freq_Audiogram = Freq_ANSI_S36_1996_Augiogram; �s�v
    % Table.SPLatHL0dB_Audiogram = SPLdBatHL0dB_ANSI_S36_1996_Augiogram; �s�v
    % �I�[�W�I���[�^�̎��g���̂݃s�b�N�A�b�v�@�F�@�Ӗ��Ȃ��C������̂ł�߂�B�O�ōs���Ηǂ��B    
    
return;

%% %%%%%%%%%%%%%%%%%%%%%%%%%

% ------------------------------------------------------------
% Information:���܂܂ł̌o��
% ------------------------------------------------------------
%
% Note:
% Rion AA-79 AD-02
% http://www.rion.co.jp/dbcon/pdf/AA-79.pdf
%
% http://www20.big.or.jp/~ent/kikoe/db_hz.htm
%�E�I�[�W�I���[�^�ł̏������͌����łO���a�͂i�h�r�K�i�ɂ��A�W���J�b�v���[�i�m�a�r�X�`�J�b�v���[�j���ŕ\�̉����ɂȂ�悤�ɒ�߂��Ă���B
%
% ���̉����͏��p����Ă��鍑�Y��b��ɂ���Ă��ꂼ���߂��Ă���A�\�́i�@�j���̒l�͂`�c?�O�Q�̏ꍇ�ł��B
% �������ŏ��̉����A�ŏ���臒l�����̕\�ł���Ƃ��A���̓��x�����O���a�ł���Ƃ����܂��B
% ������傫�Ȓl�̎��́A��ƂȂ鉺�\�̒l�Ƃ̍��ɏ]���A���̓��x���v���X�����a�i�g�k�j�ƌ����܂��B
%
% �I�[�W�I���[�^�̏o�̓��x���ڐ��肪�O���a�̎��̌������̋����͕\�̂Ƃ���ł��B
%
% ���g�� �g��	125	250	500	1000	1500	2000	3000	4000	6000	8000
% �����@���a��	45.5	24.5	11.0	6.5	6.5	8.5	7.5	9.0	8.0	9.5
% 0dB��20��Pa	(47.5)	(27.0)	(13.0)	(7.0)	(6.5)	(7.0)	(8.0)	(9.5)	(12.0)	(16.5)
%
%�E�X�s�[�J���̉���ł̉����r�o�k�����a�g�k�Ɋ��Z����ꍇ�̌v�Z
% �Q�T�O�g���͂��a�r�o�k�͂��a�g�k�ɂP�S�A�T�O�O�g���͂X�A�P�O�O�O�g���͂V�A�Q�O�O �O�g���͂S�A�S�O�O�O�g����?�P�𑫂��܂��Ƃ��a�g�k�����a�r�o�k�Ɋ��Z�ł��܂��B
%
% SPLdBatHL0dB_Kikoe  = [45.5 24.5 11.0 NaN 6.5  6.5  8.5  7.5  9.0   8.0  9.5];
% SPLdBatHL0dB_AD02   = [47.5 27.0 13.0 NaN 7.0  6.5  7.0  8.0  9.5  12.0 16.5];
%
% SPLdBatHL0dB_AA79   = [45.0 27.0 13.5 9.0 7.5  7.5  9.0  11.5 12.0 16.0 15.5];
%      ���C��:0dB = 20��Pa(IEC 60318-1�l�H���ɂ��)
%
% ����
% http://www.nihon-iryouki.jp/index.php?main_page=page&id=13&chapter=0
% SPLdBatHL0dB_NichiI = [NaN  NaN  13.5 NaN 7.5  NaN  9.0  11.5 12  16   NaN]; % NichiI
%
% http://www.audiology-japan.jp/yougo/AudiologyJapanYougo.pdf
% 
% ------------------------------------------------------------
%
%  Memo:  AA79��reference�Ƃ��ėp���邱�Ƃɂ��Ă��܂��B29 Feb 2012�@
%         SPLdBatHL0dB_AA79�Ƃ����ϐ����������������ߒǉ��B�i�l�͕ω������j�@7 Jan 2014
%
% ------------------------------------------------------------
%
%  Note: 21 Feb 2018
% ANSI_S3.9-1996�̏��
% http://hearinglosshelp.com/blog/understanding-the-difference-between-sound-pressure-level-spl-and-hearing-level-hl-in-measuring-hearing-loss/
%
%
%FreqRef               = [125  250  500  750 1000 1500 2000 3000 4000 6000 8000];
%SPLdBatHL0dB_ANSI_S39_1996     = [45.0 27.0 13.5 9.0 7.5  7.5  9.0  11.5 12.0 16.0 15.5];
% ����́ASPLdBatHL0dB_AA79�ō̗p����Ă�����̂Ɠ���
% SPLdBatHL0dB_AD02B  = [45.0 27.0 13.5 9.0 7.5  7.5  9.0  11.5 12.0 16.0 15.5]; % Rion AA-79
% SPLdBatHL0dB_Kikoe  = [45.5 24.5 11.0 NaN 6.5  6.5  8.5  7.5  9.0   8.0  9.5];
% SPLdBatHL0dB_AD02   = [47.5 27.0 13.0 NaN 7.0  6.5  7.0  8.0  9.5  12.0 16.5];
% SPLdBatHL0dB_NichiI = [NaN  NaN  13.5 NaN 7.5  NaN  9.0  11.5 12  16   NaN]; % NichiI



