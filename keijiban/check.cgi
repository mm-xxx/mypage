#!/usr/local/bin/perl

#��������������������������������������������������������������������
#�� CHARM BOARD : check.cgi - 2014/10/18
#�� copyright (c) KentWeb
#�� http://www.kent-web.com/
#��������������������������������������������������������������������

# ���W���[���錾
use strict;
use CGI::Carp qw(fatalsToBrowser);

# �O���t�@�C����荞��
require './init.cgi';
my %cf = set_init();

print <<EOM;
Content-type: text/html; charset=shift_jis

<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=shift_jis">
<title>Check Mode</title>
</head>
<body>
<b>Check Mode: [ $cf{version} ]</b>
<ul>
EOM

# ���O�t�@�C��
my %log = (
	logfile => '���O�t�@�C��',
	msgfile => '�Ǘ��R�����g�t�@�C��',
	);
foreach ( keys(%log) ) {
	if (-e $cf{$_}) {
		print "<li>$log{$_}�p�X : OK\n";
		if (-r $cf{$_} && -w $cf{$_}) {
			print "<li>$log{$_}�p�[�~�b�V���� : OK\n";
		} else {
			print "<li>$log{$_}�p�[�~�b�V���� : NG\n";
		}
	} else {
		print "<li>$log{$_}�p�X : NG\n";
	}
}

# �e���v���[�g
foreach (qw(bbs note error message find)) {
	if (-f "$cf{tmpldir}/$_.html") {
		print "<li>�e���v���[�g( $_.html ) : OK\n";
	} else {
		print "<li>�e���v���[�g( $_.html ) : NG\n";
	}
}

# Image-Magick����m�F
eval { require Image::Magick; };
if ($@) {
	print "<li>Image-Magick����: NG\n";
} else {
	print "<li>Image-Magick����: OK\n";
}

print <<EOM;
</ul>
</body>
</html>
EOM
exit;

