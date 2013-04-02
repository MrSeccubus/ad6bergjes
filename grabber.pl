#!/usr/bin/perl
# License: http://www.apache.org/licenses/LICENSE-2.0.txt


use strict;
use LWP::Simple;
use URI::Escape;

my ( %data );

# Load configuration
$data{total}->{donatie} = 0;
$data{total}->{toezegging} = 0;
open(CONF, "config.txt") or die "unable to open config.txt";
while(<CONF>) {
	chomp;
	my ($type, $nick, $url) = split;
	if ( $type eq "TEAM" ) {
		print "Team: $nick\n";
		# get team total
		get_team($nick, $url);
	} elsif ( $type eq "PEEP" ) {
		print "Peep: $nick\n";
		get_peep($nick, $url);
	} elsif ( $type eq "TOTAL" ) {
		foreach my $sub ( split /\,/, $url ) {
			$data{total}->{donatie} += $data{$sub}->{donatie};
			$data{total}->{toezegging} += $data{$sub}->{toezegging};
		}
	} elsif ( $type =~ /^\#/ ) {
		# Skip comments
	} else {
		die "Unknown type $type on line $_";
	}
}
close CONF;
$data{total}->{doel} = 150000;

open(DON, ">donaties.txt") or die "unable to open donaties";
print DON "Nick\tDoel\tDonaties\tToegezegd\tTitel\tSubtitel\tIntro\tImg\tUrl\n";
foreach my $nick ( sort keys %data ) {
	print DON "$nick\t$data{$nick}->{doel}\t$data{$nick}->{donatie}\t$data{$nick}->{toezegging}\t$data{$nick}->{titel}\t$data{$nick}->{subtitel}\t$data{$nick}->{intro}\t$data{$nick}->{img}\t$data{$nick}->{url}\n";
}
exit;

sub get_team($$) {
	my $nick = shift;
	my $url = shift;

	my $doc = get $url;
	$doc =~ s/[^\x00-\x7f]//g;
	my @doc = split /\n/, $doc;

	my $line = shift @doc;
	while ( $line !~ /Streefbedrag/ ) {
		$line = shift @doc;
	}
	while ( $line !~ /\d+\,\d\d/ ) {
		$line = shift @doc;
	}
	$line =~ s/\.//g;
	$line =~ s/\,/\./;
	$line =~ s/[^\d\.]//g;
	$data{$nick}->{doel} = $line;

	while ( $line !~ /Gedoneerd/ ) {
		$line = shift @doc;
	}
	while ( $line !~ /\d+\,\d\d/ ) {
		$line = shift @doc;
	}
	$line =~ s/\.//g;
	$line =~ s/\,/\./;
	$line =~ s/[^\d\.]//g;
	$data{$nick}->{donatie} = $line;

	while ( $line !~ /Toezeggingen/ && $line ) {
		$line = shift @doc;
	}
	while ( $line !~ /\d+\,\d\d/ && $line) {
		$line = shift @doc;
	}
	$line =~ s/\.//g;
	$line =~ s/\,/\./;
	$line =~ s/[^\d\.]//g;
	$data{$nick}->{toezegging} = $line;
}

sub get_peep($$) {
	my $nick = shift;
	my $url = shift;

	# Initialize values
	$data{$nick}->{donatie} = 0;
	$data{$nick}->{toezegging} = 0;
	$data{$nick}->{titel} = " ";
	$data{$nick}->{subtitel} = " ";
	$data{$nick}->{intro} = " ";
	$data{$nick}->{url} = $url;

	#my $doc = get "$url/widgetdata.aspx";
	my $doc = get "$url";
	$doc =~ s/[^\x00-\x7f]//g;
	my @doc = split /\n/, $doc;

	my $line = shift @doc;
	chomp $line;
	while ( $line !~ /class="actionbanner"/ && $line ) {
		chomp $line;
		$line = shift @doc;
	}
	#die $doc;
	while ( $line !~ /class="tdbuttonsupport"/ && $line ) {
		$line = shift @doc;
		chomp $line;
		if ( $line =~ /class="actionbannerimage"/ ) {
			$line = shift @doc;
			$line =~ /src=\"(http\:\/\/.*?)\"/;
			$data{$nick}->{img} = $1;
		} elsif ( $line =~ /<h2>/ ) {
			$line =~ /<h2>(.*)<\/h2>/;
			$data{$nick}->{titel} = $1;
		} elsif ( $line =~ /<h3>/ && $line ) {
			$line =~ /<h3>(.*)<\/h3>/;
			$data{$nick}->{subtitel} = $1;
		} elsif ( $line =~ /<span>/ ) {
			$line =~ s/<span>//;
			while ( $line !~ /<\/span>/ ) {
				$data{$nick}->{intro} .= $line;
				$line = shift @doc;
			}
			$line =~ s/\s*<\/span>//;
			$data{$nick}->{intro} .= $line;
		} elsif ( $line =~ /targetamountvalue/ ) {
			$line =~ s/\<.*?\>//g;
			$line =~ s/\.//g;
			$line =~ s/\,/\./;
			$line =~ s/[^\d\.]//g;
			$data{$nick}->{doel} = $line;
		}
	}
	while ( $line !~ /sidebaritem_actionsummary/ && $line ) {
		$line = shift @doc;
		chomp $line;
	}
	while ( $line !~ /class="totalresult"/ && $line ) {
		$line = shift @doc;
		chomp $line;
		if ( $line =~ /Gedoneerd/ ) {
			$line = shift @doc;
			$line =~ s/\<.*?\>//g;
			$line =~ s/\.//g;
			$line =~ s/\,/\./;
			$line =~ s/[^\d\.]//g;
			$data{$nick}->{donatie} = $line;
		} elsif ( $line =~ /Toegezegd/ ) {
			$line = shift @doc;
			$line =~ s/\<.*?\>//g;
			$line =~ s/\.//g;
			$line =~ s/\,/\./;
			$line =~ s/[^\d\.]//g;
			$data{$nick}->{toezegging} = $line;
		}
	}

	#die $line;
	#die $doc;

	#print DON "$nick\t$data{$nick}->{doel}\t$data{$nick}->{donatie}\t$data{$nick}->{toezegging}\t$data{$nick}->{titel}\t$data{$nick}->{subtitel}\t$data{$nick}->{intro}\t$data{$nick}->{img}\n";
}
