#!/usr/local/bin/perl

#��������������������������������������������������������������������
#�� CHARM BOARD : init.cgi - 2014/10/18
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

# ��������
if ($in{mode} eq 'reg_log') { reg_log(); }
if ($in{mode} eq 'del_log') { del_log(); }
if ($in{mode} eq 'find') { find_data(); }
if ($in{mode} eq 'note') { note_page(); }
bbs_list();

#-----------------------------------------------------------
#  �f�����X�g
#-----------------------------------------------------------
sub bbs_list {
	my $pg = $in{pg} || 0;

	my ($i,@log);
	open(IN,"$cf{logfile}") or error("open err: $cf{logfile}");
	while (<IN>) {
		my ($no,$date,$name,$msg,$col,$ico,$pw,$hos,$res,$col2,$ico2,$chk,$tim,$sub) = split(/<>/);

		# �`�F�b�N�@�\
		next if ($cf{adminCheck} && $chk eq '0');

		$i++;
		next if ($i < $pg + 1);
		next if ($i > $pg + $cf{pg_max});

		chomp;
		push(@log,$_);
	}
	close(IN);

	# �J�z�{�^���쐬
	my $page_btn = make_pager($i,$pg);

	# �Ǘ����b�Z�[�W
	open(IN,"$cf{msgfile}") or error("open err: $cf{msgfile}");
	my $msg = <IN>;
	close(IN);
	
	$msg = tag($msg);

	# �N�b�L�[�擾
	my ($ck_nam,$ck_col) = get_cookie();

	# �����F
	my $color;
	my @col = split(/\s+/,$cf{color});
	foreach (0 .. $#col) {
		if ($ck_col == $_) {
			$color .= qq|<input type="radio" name="color" value="$_" checked="checked" />|;
		} else {
			$color .= qq|<input type="radio" name="color" value="$_" />|;
		}
		$color .= qq|<span style="color:$col[$_]">��</span>\n|;
	}

	# �A�C�R��
	my $smile;
	my @smile = split(/\s+/,$cf{smile});
	foreach (0 .. $#smile) {
		$smile .= qq|<a href="javascript:face('{ico:$_}')"><img src="$cf{imgurl}/$smile[$_]" alt="" /></a>|;
	}

	# �e���v���[�g�Ǎ�
	open(IN,"$cf{tmpldir}/bbs.html") or error("open err: bbs.html");
	my $tmpl = join('', <IN>);
	close(IN);

	# �摜�F�؍쐬
	my ($str_plain,$str_crypt);
	if ($cf{use_captcha} > 0) {
		require $cf{captcha_pl};
		($str_plain, $str_crypt) = cap::make($cf{captcha_key},$cf{cap_len});
	} else {
		$tmpl =~ s/<!-- captcha_begin -->.+<!-- captcha_end -->//s;
	}

	# �����u������
	$tmpl =~ s/!([a-z]+_cgi)!/$cf{$1}/g;
	$tmpl =~ s/!homepage!/$cf{homepage}/g;
	$tmpl =~ s/!page_btn!/$page_btn/g;
	$tmpl =~ s/!form_name!/$ck_nam/g;
	$tmpl =~ s/!color!/$color/g;
	$tmpl =~ s/!icon!/$smile/g;
	$tmpl =~ s/!str_crypt!/$str_crypt/g;
	$tmpl =~ s/!message!/$msg/g;

	# �e���v���[�g����
	my ($head,$loop,$foot) = $tmpl =~ /(.+)<!-- loop_begin -->(.+)<!-- loop_end -->(.+)/s
			? ($1,$2,$3)
			: error("�e���v���[�g�s��");

	# �w�b�_�\��
	print "Content-type: text/html; charset=shift_jis\n\n";
	print $head;

	my $i;
	foreach (@log) {
		$i++;
		my ($no,$date,$name,$com,$col,$ico,$pw,$hos,$res,$col2,$ico2,$chk,$tim,$sub) = split(/<>/);
		$com = autolink($com) if ($cf{autolink});
		$com =~ s|\{ico:(\d+)\}|<img src="$cf{imgurl}/$smile[$1]" alt="" />|g;
		$res =~ s|\{ico:(\d+)\}|<img src="$cf{imgurl}/$smile[$1]" alt="" />|g;
		$sub ||= '����';

		my $tmp = $loop;
		$tmp =~ s/!num!/$no/g;
		$tmp =~ s/!comment!/<span style="color:$col[$col]">$com<\/span>/g;
		$tmp =~ s/!date!/$date/g;
		$tmp =~ s/!name!/$name/g;
		$tmp =~ s/!sub!/$sub/g;
		$tmp =~ s|<!-- res -->|<div style="color:$col[$col2]" class="res">$res</div>|g;
		print $tmp;
	}

	footer($foot);
}

#-----------------------------------------------------------
#  �L������
#-----------------------------------------------------------
sub reg_log {
	# ���e�`�F�b�N
	if ($cf{postonly} && $ENV{REQUEST_METHOD} ne 'POST') {
		error("�s���ȃ��N�G�X�g�ł�");
	}

	# ���̓`�F�b�N
	check_form();

	# �z�X�g�擾
	my ($host,$addr) = get_host();

	# �폜�L�[�Í���
	my $pwd = encrypt($in{pwd}) if ($in{pwd} ne "");

	# ���Ԏ擾
	my $time = time;
	my ($min,$hour,$mday,$mon,$year,$wday) = (localtime($time))[1..6];
	my @wk = ('Sun','Mon','Tue','Wed','Thu','Fri','Sat');
	my $date = sprintf("%04d/%02d/%02d(%s) %02d:%02d",
				$year+1900,$mon+1,$mday,$wk[$wday],$hour,$min);

	# �擪�L���ǂݎ��
	open(DAT,"+< $cf{logfile}") or error("open err: $cf{logfile}");
	eval "flock(DAT, 2);";
	my $top = <DAT>;

	# �d�����e�`�F�b�N
	my ($no,$nam,$com,$hos,$tim) = (split(/<>/,$top))[0,2,3,7,12];
	if ($in{name} eq $nam && $in{comment} eq $com) {
		close(DAT);
		error("��d���e�͋֎~�ł�");
	}

	# �A�����e�`�F�b�N
	my $flg;
	if ($cf{regCtl} == 1) {
		if ($host eq $hos && $time - $tim < $cf{wait}) { $flg = 1; }
	} elsif ($cf{regCtl} == 2) {
		if ($time - $tim < $cf{wait}) { $flg = 1; }
	}
	if ($flg) {
		close(DAT);
		error("���ݓ��e�������ł��B�������΂炭�����Ă��瓊�e�����肢���܂�");
	}

	# �L��No�̔�
	$no++;

	# �L��������
	my @data = ($top);
	my $i = 0;
	while (<DAT>) {
		$i++;
		push(@data,$_);

		last if ($i >= $cf{maxlog}-1);
	}

	# �X�V
	seek(DAT, 0, 0);
	print DAT "$no<>$date<>$in{name}<>$in{comment}<>$in{color}<><>$pwd<>$host<><><><>0<>$time<>$in{sub}<>\n";
	print DAT @data;
	truncate(DAT, tell(DAT));
	close(DAT);

	# ���[���ʒm
	mail_to($date,$host) if ($cf{mailing} == 1);

	# �N�b�L�[�i�[
	set_cookie($in{name},$in{color});

	# �������
	message("���肪�Ƃ��������܂��B�L�����󗝂��܂����B");
}

#-----------------------------------------------------------
#  ���[�U�L���폜
#-----------------------------------------------------------
sub del_log {
	# ���e�`�F�b�N
	if ($cf{postonly} && $ENV{REQUEST_METHOD} ne 'POST') {
		error("�s���ȃ��N�G�X�g�ł�");
	}

	# ���̓`�F�b�N
	if ($in{num} eq '' or $in{pwd} eq '') {
		error("�폜No�܂��͍폜�L�[�����̓����ł�");
	}

	my ($flg,$crypt,@log);
	open(DAT,"+< $cf{logfile}") or error("open err: $cf{logfile}");
	eval "flock(DAT, 2);";
	while (<DAT>) {
		my ($no,$date,$name,$msg,$col,$ico,$pw,$hos,$res,$col2,$ico2,$chk,$tim,$sub) = split(/<>/);

		if ($in{num} == $no) {
			$flg++;
			$crypt = $pw;
			next;
		}
		push(@log,$_);
	}

	if (!$flg or $crypt eq '') {
		close(DAT);
		error("�폜�L�[���ݒ肳��Ă��Ȃ������͋L������������܂���");
	}

	# �폜�L�[���ƍ�
	if (decrypt($in{pwd},$crypt) != 1) {
		close(DAT);
		error("�F�؂ł��܂���");
	}

	# ���O�X�V
	seek(DAT, 0, 0);
	print DAT @log;
	truncate(DAT, tell(DAT));
	close(DAT);
	
	# ����
	message("�L�����폜���܂���");
}

#-----------------------------------------------------------
#  ���[�h����
#-----------------------------------------------------------
sub find_data {
	# ����
	$in{cond} =~ s/\D//g;
	$in{word} =~ s|<br />||g;

	# ���������v���_�E��
	my %op = (1 => 'AND', 0 => 'OR');
	my $op_cond;
	foreach (1,0) {
		if ($in{cond} eq $_) {
			$op_cond .= qq|<option value="$_" selected="selected">$op{$_}</option>\n|;
		} else {
			$op_cond .= qq|<option value="$_">$op{$_}</option>\n|;
		}
	}

	# �������s
	if ($cf{conv_code} == 1) {
		require Jcode;
		$in{word} = Jcode->new($in{word})->sjis;
	}
	my @log = search($in{word},$in{cond}) if ($in{word} ne '');

	# �����F
	my @col = split(/\s+/,$cf{color});

	# �A�C�R��
	my $smile;
	my @smile = split(/\s+/,$cf{smile});
	foreach (0 .. $#smile) {
		$smile .= qq|<a href="javascript:face('{ico:$_}')"><img src="$cf{imgurl}/$smile[$_]" alt="" /></a>|;
	}

	# �e���v���[�g�ǂݍ���
	open(IN,"$cf{tmpldir}/find.html") or error("open err: find.html");
	my $tmpl = join('', <IN>);
	close(IN);

	# �����O�̂Ƃ�
	if ($in{word} eq '') {
		$tmpl =~ s/<!-- msg_begin -->.+<!-- msg_end -->//s;
	} else {
		my $hit = @log > 0 ? @log : 0;
		$tmpl =~ s/!hit!/$hit/g;
	}

	# �����u��
	$tmpl =~ s/!bbs_cgi!/$cf{bbs_cgi}/g;
	$tmpl =~ s/<!-- op_cond -->/$op_cond/;
	$tmpl =~ s/!word!/$in{word}/;

	# �e���v���[�g����
	my ($head,$loop,$foot) = $tmpl =~ /(.+)<!-- loop_begin -->(.+)<!-- loop_end -->(.+)/s
			? ($1,$2,$3)
			: error("�e���v���[�g�s��");

	# �w�b�_��
	print "Content-type: text/html; charset=shift_jis\n\n";
	print $head;

	# ���[�v��
	foreach (@log) {
		my ($no,$date,$name,$com,$col,$ico,$pw,$hos,$res,$col2,$ico2,$chk,$tim,$sub) = split(/<>/);
		$com = autolink($com) if ($cf{autolink});
		$com =~ s|\{ico:(\d+)\}|<img src="$cf{imgurl}/$smile[$1]" alt="" />|g;
		$res =~ s|\{ico:(\d+)\}|<img src="$cf{imgurl}/$smile[$1]" alt="" />|g;
		$sub ||= '����';

		my $tmp = $loop;
		$tmp =~ s/!num!/$no/g;
		$tmp =~ s/!date!/$date/g;
		$tmp =~ s/!name!/$name/g;
		$tmp =~ s/!comment!/<span style="color:$col[$col]">$com<\/span>/g;
		$tmp =~ s/!sub!/$sub/g;
		$tmp =~ s|<!-- res -->|<div style="color:$col[$col2]" class="res">$res</div>|g;
		print $tmp;
	}

	# �t�b�^
	footer($foot);
}

#-----------------------------------------------------------
#  �������s
#-----------------------------------------------------------
sub search {
	my ($word,$cond) = @_;

	# �L�[���[�h��z��
	$word =~ s/�@/ /g;
	my @wd = split(/\s+/,$word);

	# �L�[���[�h���������iShift-JIS��`�j
	my $ascii = '[\x00-\x7F]';
	my $hanka = '[\xA1-\xDF]';
	my $kanji = '[\x81-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]';

	# ��������
	my @log;
	open(IN,"$cf{logfile}") or error("open err: $cf{logfile}");
	while (<IN>) {
		my ($no,$date,$name,$com,$col,$ico,$pw,$hos,$res,$col2,$ico2,$chk,$tim,$sub) = split(/<>/);

		my $flg;
		foreach my $wd (@wd) {
			if ("$sub $name $com" =~ /^(?:$ascii|$hanka|$kanji)*?\Q$wd\E/i) {
				$flg++;
				if ($cond == 0) { last; }
			} else {
				if ($cond == 1) { $flg = 0; last; }
			}
		}
		next if (!$flg);

		push(@log,$_);
	}
	close(IN);

	# ��������
	return @log;
}

#-----------------------------------------------------------
#  ���ӎ����\��
#-----------------------------------------------------------
sub note_page {
	open(IN,"$cf{tmpldir}/note.html") or error("open err: note.html");
	my $tmpl = join('', <IN>);
	close(IN);

	print "Content-type: text/html; charset=shift_jis\n\n";
	print $tmpl;
	exit;
}

#-----------------------------------------------------------
#  ���[�����M
#-----------------------------------------------------------
sub mail_to {
	my ($date,$host) = @_;

	# ������MIME�G���R�[�h
	require Jcode if ($cf{conv_code} == 0);
	my $msub = Jcode->new("BBS: From $in{name}",'sjis')->mime_encode;

	# �R�����g���̉��s����
	my $com = tag($in{comment});
	$com =~ s|<br />|\n|g;
	$com =~ s/{ico:\d+}//g;

	# ���[���{�����`
	my $mbody = <<"EOM";
�f���ɓ��e������܂����B

���e���F$date
�z�X�g�F$host
��  ���F$in{sub}
�����O�F$in{name}

$com
EOM

	# JIS�R�[�h�ϊ�
	$mbody = Jcode->new($mbody,'sjis')->jis;

	# sendmail�R�}���h
	my $scmd = "$cf{sendmail} -t -i";
	if ($cf{sendm_f}) {
		$scmd .= " -f $cf{mailto}";
	}

	# ���M
	open(MAIL,"| $scmd") or error("���M���s");
	print MAIL "To: $cf{mailto}\n";
	print MAIL "From: $cf{mailto}\n";
	print MAIL "Subject: $msub\n";
	print MAIL "MIME-Version: 1.0\n";
	print MAIL "Content-type: text/plain; charset=ISO-2022-JP\n";
	print MAIL "Content-Transfer-Encoding: 7bit\n";
	print MAIL "X-Mailer: $cf{version}\n\n";
	print MAIL "$mbody\n";
	close(MAIL);
}

#-----------------------------------------------------------
#  �������b�Z�[�W
#-----------------------------------------------------------
sub message {
	my ($msg) = @_;

	open(IN,"$cf{tmpldir}/message.html") or error("open err: message.html");
	my $tmpl = join('', <IN>);
	close(IN);

	$tmpl =~ s/!bbs_cgi!/$cf{bbs_cgi}/g;
	$tmpl =~ s/!message!/$msg/g;

	print "Content-type: text/html; charset=shift_jis\n\n";
	print $tmpl;
	exit;
}

#-----------------------------------------------------------
#  �t�b�^�[
#-----------------------------------------------------------
sub footer {
	my $foot = shift;

	# ���쌠�\�L�i�폜�E���ϋ֎~�j
	my $copy = <<EOM;
<p style="margin-top:2.5em;text-align:center;font-family:Verdana,Helvetica,Arial;font-size:10px;">
	- <a href="http://www.kent-web.com/" target="_top">CHARM BOARD</a> -
</p>
EOM

	if ($foot =~ /(.+)(<\/body[^>]*>.*)/si) {
		print "$1$copy$2\n";
	} else {
		print "$foot$copy\n";
		print "</body></html>\n";
	}
	exit;
}

#-----------------------------------------------------------
#  �G���[���
#-----------------------------------------------------------
sub error {
	my $err = shift;

	open(IN,"$cf{tmpldir}/error.html") or die;
	my $tmpl = join('', <IN>);
	close(IN);

	$tmpl =~ s/!error!/$err/g;

	print "Content-type: text/html; charset=shift_jis\n\n";
	print $tmpl;
	exit;
}

#-----------------------------------------------------------
#  �y�[�W����쐬
#-----------------------------------------------------------
sub make_pager {
	my ($i,$pg) = @_;

	# �y�[�W�J�z����`
	$cf{pg_max} ||= 10;
	my $next = $pg + $cf{pg_max};
	my $back = $pg - $cf{pg_max};

	# �y�[�W�J�z�{�^���쐬
	my @pg;
	if ($back >= 0 || $next < $i) {
		my $flg;
		my ($w,$x,$y,$z) = (0,1,0,$i);
		while ($z > 0) {
			if ($pg == $y) {
				$flg++;
				push(@pg,qq!<li><span>$x</span></li>\n!);
			} else {
				push(@pg,qq!<li><a href="$cf{bbs_cgi}?pg=$y">$x</a></li>\n!);
			}
			$x++;
			$y += $cf{pg_max};
			$z -= $cf{pg_max};

			if ($flg) { $w++; }
			last if ($w >= 5 && @pg >= 10);
		}
	}
	while( @pg >= 11 ) { shift(@pg); }
	my $ret = join('', @pg);
	if ($back >= 0) {
		$ret = qq!<li><a href="$cf{bbs_cgi}?pg=$back">&laquo;</a></li>\n! . $ret;
	}
	if ($next < $i) {
		$ret .= qq!<li><a href="$cf{bbs_cgi}?pg=$next">&raquo;</a></li>\n!;
	}
	
	# ���ʂ�Ԃ�
	return $ret ? qq|<ul class="pager">\n$ret</ul>| : '';
}

#-----------------------------------------------------------
#  ���������N
#-----------------------------------------------------------
sub autolink {
	my $text = shift;

	$text =~ s/(s?https?:\/\/([\w-.!~*'();\/?:\@=+\$,%#]|&amp;)+)/<a href="$1" target="_blank">$1<\/a>/g;
	return $text;
}

#-----------------------------------------------------------
#  �֎~���[�h�`�F�b�N
#-----------------------------------------------------------
sub no_wd {
	my $flg;
	foreach ( split(/,/,$cf{no_wd}) ) {
		if (index("$in{sub} $in{name} $in{comment}", $_) >= 0) {
			$flg = 1;
			last;
		}
	}
	if ($flg) { error("�֎~���[�h���܂܂�Ă��܂�"); }
}

#-----------------------------------------------------------
#  ���{��`�F�b�N
#-----------------------------------------------------------
sub jp_wd {
	if ($in{comment} !~ /[\x81-\x9F\xE0-\xFC][\x40-\x7E\x80-\xFC]/) {
		error("���b�Z�[�W�ɓ��{�ꂪ�܂܂�Ă��܂���");
	}
}

#-----------------------------------------------------------
#  URL���`�F�b�N
#-----------------------------------------------------------
sub urlnum {
	my $com = $in{comment};
	my ($num) = ($com =~ s|(https?://)|$1|ig);
	if ($num > $cf{urlnum}) {
		error("�R�����g����URL�A�h���X�͍ő�$cf{urlnum}�܂łł�");
	}
}

#-----------------------------------------------------------
#  �A�N�Z�X����
#-----------------------------------------------------------
sub get_host {
	# IP&�z�X�g�擾
	my $host = $ENV{REMOTE_HOST};
	my $addr = $ENV{REMOTE_ADDR};

	if ($cf{gethostbyaddr} && ($host eq "" || $host eq $addr)) {
		$host = gethostbyaddr(pack("C4", split(/\./, $addr)), 2);
	}

	# IP�`�F�b�N
	my $flg;
	foreach ( split(/\s+/,$cf{deny_addr}) ) {
		s/\./\\\./g;
		s/\*/\.\*/g;

		if ($addr =~ /^$_/i) { $flg = 1; last; }
	}
	if ($flg) {
		error("�A�N�Z�X��������Ă��܂���");

	# �z�X�g�`�F�b�N
	} elsif ($host) {

		foreach ( split(/\s+/,$cf{deny_host}) ) {
			s/\./\\\./g;
			s/\*/\.\*/g;

			if ($host =~ /$_$/i) { $flg = 1; last; }
		}
		if ($flg) {
			error("�A�N�Z�X��������Ă��܂���");
		}
	}
	if ($host eq "") { $host = $addr; }
	return ($host,$addr);
}

#-----------------------------------------------------------
#  crypt�Í�
#-----------------------------------------------------------
sub encrypt {
	my $in = shift;

	my @wd = ('a' .. 'z', 'A' .. 'Z', 0 .. 9, '.', '/');
	srand;
	my $salt = $wd[int(rand(@wd))] . $wd[int(rand(@wd))];
	crypt($in, $salt) || crypt ($in, '$1$' . $salt);
}

#-----------------------------------------------------------
#  crypt�ƍ�
#-----------------------------------------------------------
sub decrypt {
	my ($in,$dec) = @_;

	my $salt = $dec =~ /^\$1\$(.*)\$/ ? $1 : substr($dec, 0, 2);
	if (crypt($in, $salt) eq $dec || crypt($in, '$1$' . $salt) eq $dec) {
		return 1;
	} else {
		return 0;
	}
}

#-----------------------------------------------------------
#  �^�O����
#-----------------------------------------------------------
sub tag {
	local($_) = @_;

	s/&lt;/</g;
	s/&gt;/>/g;
	s/&quot;/"/g;
	s/&amp;/&/g;
	s/&#39;/'/g;
	$_;
}

#-----------------------------------------------------------
#  �N�b�L�[���s
#-----------------------------------------------------------
sub set_cookie {
	my @data = @_;

	my ($sec,$min,$hour,$mday,$mon,$year,$wday,undef,undef) = gmtime(time + 60*24*60*60);
	my @mon  = qw|Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec|;
	my @week = qw|Sun Mon Tue Wed Thu Fri Sat|;

	# �����t�H�[�}�b�g
	my $gmt = sprintf("%s, %02d-%s-%04d %02d:%02d:%02d GMT",
				$week[$wday],$mday,$mon[$mon],$year+1900,$hour,$min,$sec);

	# URL�G���R�[�h
	my $cook;
	foreach (@data) {
		s/(\W)/sprintf("%%%02X", unpack("C", $1))/eg;
		$cook .= "$_<>";
	}

	print "Set-Cookie: $cf{cookie_id}=$cook; expires=$gmt\n";
}

#-----------------------------------------------------------
#  �N�b�L�[�擾
#-----------------------------------------------------------
sub get_cookie {
	# �N�b�L�[�擾
	my $cook = $ENV{HTTP_COOKIE};

	# �Y��ID�����o��
	my %cook;
	foreach ( split(/;/,$cook) ) {
		my ($key,$val) = split(/=/);
		$key =~ s/\s//g;
		$cook{$key} = $val;
	}

	# URL�f�R�[�h
	my @cook;
	foreach ( split(/<>/,$cook{$cf{cookie_id}}) ) {
		s/%([0-9A-Fa-f][0-9A-Fa-f])/pack("H2", $1)/eg;
		s/[&"'<>]//g;

		push(@cook,$_);
	}
	return @cook;
}

#-----------------------------------------------------------
#  ���̓`�F�b�N
#-----------------------------------------------------------
sub check_form {
	if ($cf{no_wd}) { no_wd(); }
	if ($cf{jp_wd}) { jp_wd(); }
	if ($cf{urlnum} > 0) { urlnum(); }
	$in{name} =~ s|<br />||g;
	$in{sub}  =~ s|<br />||g;
	$in{color} =~ s/\D//g;
	
	# �摜�F�؃`�F�b�N
	if ($cf{use_captcha} > 0) {
		require $cf{captcha_pl};
		if ($in{captcha} !~ /^\d{$cf{cap_len}}$/) {
			error("�摜�F�؂����͕s���ł��B<br />���e�t�H�[���ɖ߂��čēǍ��݌�A�ē��͂��Ă�������");
		}

		# ���e�L�[�`�F�b�N
		# -1 : �L�[�s��v
		#  0 : �������ԃI�[�o�[
		#  1 : �L�[��v
		$in{str_crypt} =~ s|<br />||g;
		my $chk = cap::check($in{captcha},$in{str_crypt},$cf{captcha_key},$cf{cap_time},$cf{cap_len});
		if ($chk == 0) {
			error("�摜�F�؂��������Ԃ𒴉߂��܂����B<br />���e�t�H�[���ɖ߂��čēǍ��݌�A�w��̐������ē��͂��Ă�������");
		} elsif ($chk == -1) {
			error("�摜�F�؂��s���ł��B<br />���e�t�H�[���ɖ߂��čēǍ��݌�A�ē��͂��Ă�������");
		}
	}

	# �t�H�[�����e���`�F�b�N
	my $err;
	if ($in{name} eq "") { $err .= "���O�����͂���Ă��܂���<br />\n"; }
	elsif (length($in{name}) > $cf{max_name}*2) { $err .= "���O�͑S�p$cf{max_name}���ȓ��ł�<br />\n"; }
	if ($in{comment} eq "") { $err .= "�R�����g�����͂���Ă��܂���<br />\n"; }
	if (length($in{sub}) > $cf{max_sub}*2) { $err .= "�^�C�g���͑S�p$cf{max_sub}���ȓ��ł�<br />\n"; }
	if ($err) { error($err); }

	# �R�[�h�ϊ�
	if ($cf{conv_code} == 1) {
		require Jcode;
		$in{name} = Jcode->new($in{name})->sjis;
		$in{comment} = Jcode->new($in{comment})->sjis;
	}
}

