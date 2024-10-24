#!/usr/local/bin/perl

#��������������������������������������������������������������������
#�� CHARM BOARD : admin.cgi - 2014/10/18
#�� copyright (c) KentWeb
#�� http://www.kent-web.com/
#��������������������������������������������������������������������

# ���W���[���錾
use strict;
use CGI::Carp qw(fatalsToBrowser);

# �ݒ�t�@�C���F��
require "./init.cgi";
my %cf = set_init();

# �f�[�^��
my %in = parse_form();

# �F��
check_passwd();

# �Ǘ����[�h
admin_mode();

#-----------------------------------------------------------
#  �Ǘ����[�h
#-----------------------------------------------------------
sub admin_mode {
	# �Ǘ��҃R�����g
	if ($in{job} eq "msg" && $in{msg}) {

		# �Ǘ��p�f�[�^�X�V
		open(OUT,"+> $cf{msgfile}") or error("write err: $cf{msgfile}");
		print OUT $in{msg};
		close(OUT);

		message("�Ǘ��҃R�����g���C�����܂���");

	# �폜
	} elsif ($in{job} eq "del" && $in{no}) {

		# ���O�ǂݍ���
		my @data;
		open(DAT,"+< $cf{logfile}") or error("open err: $cf{logfile}");
		eval "flock(DAT, 2);";
		while (<DAT>) {
			my ($no) = (split(/<>/))[0];
			next if ($in{no} == $no);

			push(@data,$_);
		}

		# �X�V
		seek(DAT, 0, 0);
		print DAT @data;
		truncate(DAT, tell(DAT));
		close(DAT);

	# �C�����
	} elsif ($in{job} eq "men" && $in{no}) {

		# �Y���L�����o
		my $log;
		open(IN,"$cf{logfile}") or error("open err: $cf{logfile}");
		while (<IN>) {
			my ($no,$date,$name,$msg,$col,$ico,$pw,$hos,$res,$col2,$ico2,$chk,$tim,$sub) = split(/<>/);

			if ($in{no} == $no) {
				chomp;
				$log = $_;
				last;
			}
		}
		close(IN);

		# �C���t�H�[����
		chomp($log);
		edit_form($log);

	# �C�����s
	} elsif ($in{job} eq "edit") {

		# �R�[�h�ϊ�
		if ($cf{conv_code} == 1) {
			require "./lib/Jcode.pm";
			$in{name} = Jcode->new($in{name})->sjis;
			$in{comment} = Jcode->new($in{comment})->sjis;
			$in{reply} = Jcode->new($in{reply})->sjis;
		}

		# ���O�ǂݍ���
		my @data;
		open(DAT,"+< $cf{logfile}") or error("open err: $cf{logfile}");
		eval "flock(DAT, 2);";
		while (<DAT>) {
			chomp;
			my ($no,$date,$name,$msg,$col,$ico,$pw,$hos,$res,$col2,$ico2,$chk,$tim,$sub) = split(/<>/);

			if ($in{no} == $no) {
				if ($cf{adminCheck} == 1) { $chk = $in{chk}; }
				$_ = "$no<>$date<>$in{name}<>$in{comment}<>$in{color}<><>$pw<>$hos<>$in{reply}<>$in{color2}<><>$chk<>$tim<>$in{sub}<>";
			}
			push(@data,"$_\n");
		}

		# �X�V
		seek(DAT, 0, 0);
		print DAT @data;
		truncate(DAT, tell(DAT));
		close(DAT);

		message("�L�����C�����܂���");

	# ����
	} elsif ($in{job} eq "auth" && $in{no}) {

		# ���O�ǂݍ���
		my @data;
		open(DAT,"+< $cf{logfile}") or error("open err: $cf{logfile}");
		eval "flock(DAT, 2);";
		while (<DAT>) {
			chomp;
			my ($no,$date,$name,$msg,$col,$ico,$pw,$hos,$res,$col2,$ico2,$chk,$tim,$sub) = split(/<>/);

			if ($in{no} == $no) {
				$chk = $chk ? 0 : 1;
				$_ = "$no<>$date<>$name<>$msg<>$col<>$ico<>$pw<>$hos<>$res<>$col2<>$ico2<>$chk<>$tim<>$sub<>";
			}
			push(@data,"$_\n");
		}

		# �X�V
		seek(DAT, 0, 0);
		print DAT @data;
		truncate(DAT, tell(DAT));
		close(DAT);
	}

	# �Ǘ��҃R�����g
	open(IN,"$cf{msgfile}") or &error("open err: $cf{msgfile}");
	my $msg = <IN>;
	close(IN);

	header("�Ǘ����[�h");
	print <<EOM;
<form action="$cf{bbs_cgi}">
<input type="submit" value="�f����">
<input type="button" value="���O�I�t" onclick="window.open('$cf{admin_cgi}','_self')">
</form>
<form action="$cf{admin_cgi}" method="post">
<input type="hidden" name="job" value="msg">
<input type="hidden" name="pass" value="$in{pass}">
���Ǘ��҃R�����g (HTML�^�O�L���B���s����)<br>
<textarea name="msg" cols="60" rows="4">$msg</textarea><br>
<input type="submit" value="�X�V����">
</form>
���L�������e�i���X
<form action="$cf{admin_cgi}" method="post">
<input type="hidden" name="pass" value="$in{pass}">
�����F
<select name="job">
EOM

	if ($cf{adminCheck}) {
		print "<option value=\"auth\">����\n";
	}

	print <<EOM;
<option value="men">�ԐM/�C��
<option value="del">�폜
</select>
<input type="submit" value="���M����">
EOM

	# ���O�W�J
	open(IN,"$cf{logfile}") or error("open err: $cf{logfile}");
	while (<IN>) {
		my ($no,$date,$name,$msg,$col,$ico,$pw,$hos,$res,$col2,$ico2,$chk,$tim,$sub) = split(/<>/);
		$msg = cut_str($msg);

		print qq|<hr><input type="radio" name="no" value="$no">\n|;

		# �`�F�b�N�@�\
		if ($cf{adminCheck} && $chk eq '0') {
			print "�y���f�ځz\n";
		}

		print qq|[$no] <b class="sub">$sub</b> ���e�ҁF$name �����F$date �y$hos�z<br>\n|;
		print qq|<div class="msg">$msg</div>\n|;
		print qq|<div class="res">[�ԐM] $res</div>| if ($res);
	}
	close(IN);

	print <<EOM;
<hr>
</form>
</body>
</html>
EOM
	exit;
}

#-----------------------------------------------------------
#  �C���t�H�[��
#-----------------------------------------------------------
sub edit_form {
	my $log = shift;
	my ($no,$date,$name,$msg,$col,$ico,$pw,$hos,$res,$col2,$ico2,$chk,$tim,$sub) = split(/<>/,$log);
	$msg =~ s|<br( /)?>|\n|g;

	my @ico = split(/\s+/,$cf{smile});
	my ($icon,$icon2);
	foreach (0 .. $#ico) {
		$icon .= qq|<a href="javascript:face('{ico:$_}')"><img src="$cf{imgurl}/$ico[$_]"></a>|;
	}
	foreach (0 .. $#ico) {
		$icon2 .= qq|<a href="javascript:face2('{ico:$_}')"><img src="$cf{imgurl}/$ico[$_]"></a>|;
	}

	my @col = split(/\s+/,$cf{color});

	header("�C���t�H�[��", "js");
	print <<EOM;
<form action="$cf{admin_cgi}" method="post">
<input type="hidden" name="pass" value="$in{pass}">
<input type="submit" value="&lt; �O���">
</form>
<ul>
<li>�ύX���镔���̂ݏC�����Ă��������B
<li>�ԐM�͕ԐM���ɋL�����Ă��������B
</ul>
<form action="$cf{admin_cgi}" method="post" name="bbsform">
<input type="hidden" name="job" value="edit">
<input type="hidden" name="no" value="$in{no}">
<input type="hidden" name="pass" value="$in{pass}">
<table class="form">
<tr>
	<th>����</th>
	<td><input type="text" name="sub" size="40" value="$sub"></td>
</tr><tr>
	<th>���O</th>
	<td><input type="text" name="name" size="40" value="$name"></td>
</tr><tr>
	<th>�{��</th>
	<td class="com">
		$icon<br>
		<textarea name="comment" cols="55" rows="7">$msg</textarea><br>
		[�����F]
EOM

	foreach (0 .. $#col) {
		if ($col == $_) {
			print qq|<input type="radio" name="color" value="$_" checked>|;
		} else {
			print qq|<input type="radio" name="color" value="$_">|;
		}
		print qq|<span style="color:$col[$_]">��</span>\n|;
	}

	print <<EOM;
  </td>
</tr><tr>
	<th>�ԐM</th>
	<td class="com">
		$icon2<br>
		<input type="text" name="reply" value="$res" size="60"><br>
		[�����F]
EOM

	foreach (0 .. $#col) {
		if ($col2 == $_) {
			print qq|<input type="radio" name="color2" value="$_" checked>|;
		} else {
			print qq|<input type="radio" name="color2" value="$_">|;
		}
		print qq|<span style="color:$col[$_]">��</span>\n|;
	}

	print "</td>\n";

	if ($cf{adminCheck} == 1) {
		
		print qq|</tr><tr>\n|;
		print qq|<th>�f��</th><td>\n|;
		
		my %ox = (1 => '�f�ڂ���', 0 => '�f�ڂ��Ȃ�');
		foreach (1,0) {
			if ($chk eq $_) {
				print qq|<input type="radio" name="chk" value="$_" checked>$ox{$_}\n|;
			} else {
				print qq|<input type="radio" name="chk" value="$_">$ox{$_}\n|;
			}
		}
		
		print "</td>\n";
	}

	print <<EOM;
</tr>
</table>
<input type="submit" value="���M����">
</form>
</body>
</html>
EOM
	exit;
}

#-----------------------------------------------------------
#  �p�X���[�h�F��
#-----------------------------------------------------------
sub check_passwd {
	# �p�X���[�h�������͂̏ꍇ�͓��̓t�H�[�����
	if ($in{pass} eq "") {
		enter_form();

	# �p�X���[�h�F��
	} elsif ($in{pass} ne $cf{password}) {
		error("�F�؂ł��܂���");
	}
}

#-----------------------------------------------------------
#  �������
#-----------------------------------------------------------
sub enter_form {
	header("�������");
	print <<EOM;
<div align="center">
<form action="$cf{admin_cgi}" method="post">
<table width="380" style="margin-top:50px">
<tr>
	<td height="40" align="center">
		<fieldset><legend>�Ǘ��p�X���[�h����</legend><br>
		<input type="password" name="pass" size="25">
		<input type="submit" value=" �F�� "><br><br>
		</fieldset>
	</td>
</tr>
</table>
</form>
<script language="javascript">
<!--
self.document.forms[0].pass.focus();
//-->
</script>
</div>
</body>
</html>
EOM
	exit;
}

#-----------------------------------------------------------
#  HTML�w�b�_�[
#-----------------------------------------------------------
sub header {
	my ($ttl,$js) = @_;

	print <<EOM;
Content-type: text/html; charset=shift_jis

<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=shift_jis">
<meta http-equiv="content-style-type" content="text/css">
<style type="text/css">
<!--
body,td,th { font-size:80%; background:#f0f0f0; }
.ttl { color:#004040; }
p.err { color:#dd0000; }
p.msg { color:#006400; }
table.form { border-collapse:collapse; margin:1em 0; }
table.form th,table.form td { padding:5px; border:1px solid #666; }
table.form th { background:#afafd8; }
table.form td { background:#fff; }
td.com img { border:none; vertical-align:middle; margin-right:3px; }
div.msg { margin-left:2em; font-size:90%; }
div.res { margin-left:2em; font-size:90%; color:green; }
b.sub { color:#007339; }
-->
</style>
EOM

	if ($js eq 'js') {
		print qq|<script type="text/javascript">\n|;
		print qq|<!--\nfunction face(smile) {\n|;
		print qq|bbscom = document.bbsform.comment.value;\n|;
		print qq|document.bbsform.comment.value = bbscom + smile; }\n|;
		print qq|<!--\nfunction face2(smile) {\n|;
		print qq|bbscom = document.bbsform.reply.value;\n|;
		print qq|document.bbsform.reply.value = bbscom + smile;\n|;
		print qq|}\n// -->\n</script>\n|;
	}

	print <<EOM;
<title>$ttl</title>
</head>
<body>
EOM
}

#-----------------------------------------------------------
#  �G���[
#-----------------------------------------------------------
sub error {
	my $err = shift;

	header("ERROR!");
	print <<EOM;
<div align="center">
<hr width="350">
<h3>ERROR!</h3>
<p class="err">$err</p>
<hr width="350">
<form>
<input type="button" value="�O��ʂɖ߂�" onclick="history.back()">
</form>
</div>
</body>
</html>
EOM
	exit;
}

#-----------------------------------------------------------
#  �������b�Z�[�W
#-----------------------------------------------------------
sub message {
	my $msg = shift;

	header("����");
	print <<EOM;
<div align="center" style="margin-top:3em;">
<hr width="350">
<p class="msg">$msg</p>
<hr width="350">
<form action="$cf{admin_cgi}" method="post">
<input type="hidden" name="pass" value="$in{pass}">
<input type="submit" value="�Ǘ���ʂɖ߂�">
</form>
</div>
</body>
</html>
EOM
	exit;
}

#-----------------------------------------------------------
#  �������J�b�g for Shift-JIS
#-----------------------------------------------------------
sub cut_str {
	my $str = shift;
	$str =~ s/<br>//g;

	my $i = 0;
	my $ret;
	while($str =~ /([\x00-\x7F\xA1-\xDF]|[\x81-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC])/gx) {
		$i++;
		$ret .= $1;
		last if ($i >= 40);
	}
	return $ret;
}

