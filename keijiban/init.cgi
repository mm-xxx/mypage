# ���W���[���錾/�ϐ�������
use strict;
my %cf;
#��������������������������������������������������������������������
#�� CHARM BOARD : init.cgi - 2014/10/18
#�� copyright (c) KentWeb
#�� http://www.kent-web.com/
#��������������������������������������������������������������������
$cf{version} = 'CHARM BOARD v5.0';
#��������������������������������������������������������������������
#�� [���ӎ���]
#�� 1. ���̃v���O�����̓t���[�\�t�g�ł��B���̃v���O�������g�p����
#��    �����Ȃ鑹�Q�ɑ΂��č�҂͈�؂̐ӔC�𕉂��܂���B
#�� 2. �ݒu�Ɋւ��鎿��̓T�|�[�g�f���ɂ��肢�������܂��B
#��    ���ڃ��[���ɂ�鎿��͈�؂��󂯂������Ă���܂���B
#��������������������������������������������������������������������

#===========================================================
# �� ��{�ݒ�
#===========================================================

# �Ǘ��p�p�X���[�h
$cf{password} = '0123';

# �{�̃t�@�C���yURL�p�X�z
$cf{bbs_cgi} = './charm.cgi';

# ���e�t�@�C���yURL�p�X�z
$cf{regist_cgi} = './regist.cgi';

# �Ǘ��t�@�C���yURL�p�X�z
$cf{admin_cgi} = './admin.cgi';

# �ő�L�����i����𒴂���L���͌Â����ɍ폜�j
$cf{maxlog} = 100;

# ���O�t�@�C���y�T�[�o�p�X�z
$cf{logfile} = './data/log.cgi';

# �Ǘ��҃R�����g�t�@�C���y�T�[�o�p�X�z
$cf{msgfile} = './data/msg.dat';

# �e���v���[�g�f�B���N�g���y�T�[�o�p�X�z
$cf{tmpldir} = './tmpl';

# �����F�̐ݒ�
# �� �X�y�[�X�ŋ�؂�
$cf{color} = '#800000 #DF0000 #008040 #0000FF #C100C1 #FF80C0 #FF8040 #808000';

# �X�}�C���A�C�R��
# �� �X�y�[�X�ŋ�؂�
$cf{smile} = 'coool.gif smile.gif confused.gif biggrin.gif shame.gif wink.gif cry.gif bonk.gif';

# �A�C�R���f�B���N�g���yURL�p�X�z
$cf{imgurl} = './img';

# �߂��yURL�p�X�z
$cf{homepage} = '../index.html';

# �����R�[�h�������ʁi0=no 1=yes�j
# �� �t�H�[�����͂̕����R�[�h���ʂ��s���ꍇ
$cf{conv_code} = 0;

# �L���̍X�V�� method=POST ���肷��ꍇ�i�Z�L�����e�B�΍�j
# �� 0=no 1=yes
$cf{postonly} = 1;

# �P�y�[�W������̋L���\������
$cf{pg_max} = 10;

# �Ǘ��҃`�F�b�N���f�@�\
# �i�L���͊Ǘ��҂��`�F�b�N��ɔ��f����j
# �� 0=no 1=yes
$cf{adminCheck} = 0;

# ���e������ƃ��[���ʒm���� (sendmail�K�{)
# 0 : �ʒm���Ȃ�
# 1 : �ʒm����
$cf{mailing} = 0;

# ���[���A�h���X(���[���ʒm���鎞)
$cf{mailto} = 'xxx@xxx.xx';

# sendmail�p�X�i���[���ʒm���鎞�j
$cf{sendmail} = '/usr/lib/sendmail';

# sendmail�� -f�R�}���h���K�v�ȏꍇ
# 0=no 1=yes
$cf{sendm_f} = 0;

# URL�̎��������N (0=no 1=yes)
$cf{autolink} = 1;

# ���e�����i�Z�L�����e�B�΍�j
#  0 : ���Ȃ�
#  1 : ����IP�A�h���X����̓��e�Ԋu�𐧌�����
#  2 : �S�Ă̓��e�Ԋu�𐧌�����
$cf{regCtl} = 1;

# �������e�Ԋu�i�b���j
# �� $regCtl �ł̓��e�Ԋu
$cf{wait} = 60;

# �֎~���[�h
# �� ���e���֎~���郏�[�h���R���}�ŋ�؂�
$cf{no_wd} = '';

# ���{��`�F�b�N�i���e�����{�ꂪ�܂܂�Ă��Ȃ���΋��ۂ���j
# 0=No  1=Yes
$cf{jp_wd} = 1;

# URL���`�F�b�N
# �� ���e�R�����g���Ɋ܂܂��URL���̍ő�l
$cf{urlnum} = 2;

# ���O�̓��͕���������
# �� �S�p���Z
$cf{max_name} = 15;

# �L���^�C�g���̓��͕���������
# �� �S�p���Z
$cf{max_sub} = 20;

# �P�񓖂�̍ő哊�e�T�C�Y (bytes)
$cf{maxdata} = 51200;

# �z�X�g�擾���@
# 0 : gethostbyaddr�֐����g��Ȃ�
# 1 : gethostbyaddr�֐����g��
$cf{gethostbyaddr} = 0;

# �A�N�Z�X�����i���p�X�y�[�X�ŋ�؂�A�A�X�^���X�N�j
#  �� ���ۃz�X�g�����L�q�i�����v�j�y��z*.anonymizer.com
$cf{deny_host} = '';
#  �� ����IP�A�h���X���L�q�i�O����v�j�y��z210.12.345.*
$cf{deny_addr} = '';

# �N�b�L�[ID���i���ɕύX���Ȃ��Ă悢�j
# �� �N�b�L�[�ۑ���
$cf{cookie_id} = "charm_board";

# -------------------------------------------------------------- #
# [ �ȉ��́u�摜�F�؋@�\�v�@�\�i�X�p���΍�j���g�p����ꍇ�̐ݒ� ]
#
# �摜�F�؋@�\�̎g�p
# 0 : ���Ȃ�
# 1 : ���C�u�����Łipngren.pl�j
# 2 : ���W���[���ŁiGD::SecurityImage + Image::Magick�j�� Image::Magick�K�{
$cf{use_captcha} = 1;

# �F�ؗp�摜�����t�@�C���yURL�p�X�z
$cf{captcha_cgi} = './captcha.cgi';

# �摜�F�؃v���O�����y�T�[�o�p�X�z
$cf{captcha_pl} = './lib/captcha.pl';
$cf{captsec_pl} = './lib/captsec.pl';
$cf{pngren_pl}  = './lib/pngren.pl';

# �摜�F�؋@�\�p�Í����L�[�i�Í���/�����������邽�߂̃L�[�j
# �� �K���ɕύX���Ă��������B
$cf{captcha_key} = 'capcharm';

# ���e�L�[���e���ԁi���P�ʁj
# �� ���e�t�H�[���\����A���M�{�^�����������܂ł̉\���ԁB
$cf{cap_time} = 30;

# ���e�L�[�̕�����
# ���C�u������ : 4�`8�����Őݒ�
# ���W���[���� : 6�`8�����Őݒ�
$cf{cap_len} = 6;

# �摜/�t�H���g�i�[�f�B���N�g���y�T�[�o�p�X�z
$cf{bin_dir} = './lib/bin';

# [���C�u������] �摜�t�@�C�� [ �t�@�C�����̂� ]
$cf{si_png} = "jump.png";

# [���W���[����] �摜�t�H���g [ �t�@�C�����̂� ]
$cf{font_ttl} = "tempest.ttf";

#===========================================================
# �� �ݒ芮��
#===========================================================

# �ݒ�l��Ԃ�
sub set_init {
	return %cf;
}

#-----------------------------------------------------------
#  �t�H�[���f�R�[�h
#-----------------------------------------------------------
sub parse_form {
	my ($buf,%in);
	if ($ENV{REQUEST_METHOD} eq "POST") {
		&error('�󗝂ł��܂���') if ($ENV{CONTENT_LENGTH} > $cf{maxdata});
		read(STDIN, $buf, $ENV{CONTENT_LENGTH});
	} else {
		$buf = $ENV{QUERY_STRING};
	}
	foreach ( split(/&/, $buf) ) {
		my ($key,$val) = split(/=/);
		$val =~ tr/+/ /;
		$val =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("H2", $1)/eg;

		# ������
		$val =~ s/&/&amp;/g;
		$val =~ s/</&lt;/g;
		$val =~ s/>/&gt;/g;
		$val =~ s/"/&quot;/g;
		$val =~ s/'/&#39;/g;
		$val =~ s|\r\n|<br />|g;
		$val =~ s|[\n\r]|<br />|g;

		$in{$key} .= "\0" if (defined($in{$key}));
		$in{$key} .= $val;
	}
	return %in;
}



1;

