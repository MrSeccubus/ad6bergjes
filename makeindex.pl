#!/usr/bin/perl

use strict;

open(IN, ">index.html") or die "No can do index.html";
print IN
"<html><head>
	<title>Widgets</title>
</head><body>";
open(DON, "donaties.txt") or die "No donaties.txt";
while(<DON>) {
	chomp;
	my ( $nickname, $doel, $donaties, $toezeggingen, $titel, $subtitel, $intro, $img) = split /\t/, $_;
	if ( $nickname && $nickname ne "Nick") {
		print IN "<h1>$titel ($nickname)</h1>\n";
		print IN "<a href='http://widget.sbpad6.nl/widget.pl?nick=$nickname'>widget (http://widget.sbpad6.nl/widget.pl?nick=$nickname)</a><br>\n";
		#print IN "<iframe src='http://widget.sbpad6.nl/widget.pl?nick=$nickname' width=1300px height=250px></iframe><br>\n";
		print IN "<a href='http://widget.sbpad6.nl/alpe_widget.pl?nick=$nickname'>Alpe (http://widget.sbpad6.nl/alpe_widget.pl?nick=$nickname)</a><br>\n";
		print IN "<a href='http://widget.sbpad6.nl/alpe_email.pl?nick=$nickname'>Email (http://widget.sbpad6.nl/alpe_email.pl?nick=$nickname)</a><br>\n";
		print IN "<br><a href='http://$nickname.sbpad6.nl'><img src='http://widget.sbpad6.nl/alpe_email.pl?nick=$nickname'></a><br>\n";
		
	}
}
print IN "</body></html";
close DON;
close IN;
