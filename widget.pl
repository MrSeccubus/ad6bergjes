#!/usr/bin/perl

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);

my $query = CGI::new();

print $query->header("text/html");
my $nick = shift;

$nick = $query->param("nick") unless $nick;
die "No nick" unless $nick;

open(DON, "donaties.txt") or die "Unable to open donaties.txt";
while(<DON>) {
	chomp;
	my ( $nickname, $doel, $donaties, $toezeggingen, $titel, $subtitel, $intro, $img) = split /\t/, $_;
	if ($nick eq $nickname ) {
		$intro =~ s/\\n/<br>/g;
		my $in = $donaties + $toezeggingen;
		my $percent = int((($in / $doel) * 100) + 0.5);
		$doel = sprintf("%0.2f", $doel);
		$in = sprintf("%0.2f", $in);

		if ( $nick eq "total" ) {
			print <<END
				<html>
					<head>
						<title>Schuberg Philis totaal</title>
					</head>
					<body>
						<h1>Schuberg Philis totaal</h1>
						<br>
						<b>Doel:</b> &euro; $doel
						<br>
						<b>Opgehaald:</b> &euro; $in ($percent%)
						<br>
						<img src='alpe.pl?percent=$percent&height=150'>
					</body>
				</html>
END
			
		} else {
			print <<END
				<html>
					<head>
						<title>$titel</title>
					</head>
					<body>
						<img src='$img' align=left>
						<h1>$titel</h1>
						<h2>$subtitel</h2>
						$intro
						<br>
						<b>Doel:</b> &euro; $doel
						<br>
						<b>Opgehaald:</b> &euro; $in ($percent%)
						<br>
						<img src='slider.pl?percent=$percent'>
					</body>
				</html>
END
		}
	}
}
exit;


