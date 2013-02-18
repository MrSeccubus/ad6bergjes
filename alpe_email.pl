#!/usr/bin/perl
# License: http://www.apache.org/licenses/LICENSE-2.0.txt

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use GD::Simple;

my ( $in, $percent );
my ( $nickname, $doel, $donaties, $toezeggingen, $titel, $subtitel, $intro, $img);

my $query = CGI::new();
my $nick = $query->param("nick");
$nick = shift unless $nick;
$nick = "total" unless $nick;

open(DON, "donaties.txt") or die "Unable to open donaties.txt";
while(<DON>) {
        chomp;
	( $nickname, $doel, $donaties, $toezeggingen, $titel, $subtitel, $intro, $img) = split /\t/, $_;
	if ( $nick eq $nickname)  {
		$in = $donaties + $toezeggingen;
		$percent = int((($in / $doel) * 100) + 0.5);
		last;
	}
}
close DON;
$titel = "SBPad6" if $nick eq "total";
$subtitel = undef if $subtitel == " ";

my @hoogtes = (
		724,725,744,797,848,900,950,994,1031,1067,1108,1150,1190,1225,1266,1310,1354,1390,1437,1478,1512,1533,1565,1637,1682,1723,1764,1795,1814,1815
		);
my $startat = 700;
my $stopat = 1900;


#die join "\n", GD::Simple->color_names;

print $query->header("image/png");
my $width = $query->param("width");
my $height = $query->param("height");
my ($mleft, $mright, $mtop, $mbottom) = (400,5,5,5);

$width += 0;
$height += 0;
$width = 600 unless $width;
$width = 600 if $width < 600;
$height = 120 if $height < 120;

$percent += 0;
#$percent = 101 if $percent > 100;
$percent = 0 if $percent < 0;

# O.K. lets do some math
# Drawing area
my $gx = $width-$mleft-$mright;
my $gy = $height-$mtop,$mbottom;
# Pixel per meter
my $mpp = ($stopat-$startat)/$gy;
# Stop at pixel
my $percentx = ($gx * $percent / 100) + $mleft;
$percentx = 8 if ( $percent > 0 and $percentx <8);
# Pixel per step
my $perstep = $gx / (@hoogtes - 1);

# Start drawing
my $img = GD::Simple->new($width,$height);
$img->penSize(1,1);
$img->bgcolor('white');
$img->fgcolor('blue');

$img->bgcolor('red');
$img->fgcolor('red');
my $x = $mleft;
my $current = shift @hoogtes;
$current -= $startat;
while ( @hoogtes ) {
	if ( $x < $percentx ) {
		$img->fgcolor('red');
	} else {
		$img->fgcolor('blue');
	}

	my $previous = $current;
	$current = shift @hoogtes;
	$current -= $startat;
	my $y = $previous / $mpp;
	my $upperstep = ($current-$previous) / ($perstep -1 );
	$img->moveTo($x,$height-$mbottom);
	my $y = $previous/$mpp;
	$img->lineTo($x,$height-($mtop+$y));
	for my $tx ( $x+1..$x+$perstep-1 ) {
		if ( $tx < $percentx ) {
			$img->fgcolor('red');
		} else {
			$img->fgcolor('blue');
		}
		$y += ($upperstep/$mpp);
		$img->moveTo($tx,$height-$mbottom);
		$img->lineTo($tx,$height-($mbottom+$y));
	}
	$x += $perstep;
}

#$img->bgcolor('red');
$img->fgcolor('white');
$img->font('/usr/share/fonts/corefonts/georgiab.ttf');
$img->fontsize(9);
my ($stringx , $stringy) = $img->stringBounds("$titel");
$img->moveTo($mleft+($gx/2)-($stringx/4),($height-$mbottom-14));
$img->string("$titel");

my $string = sprintf("\xE2\x82\xAC %d (%d%)", $in, $percent);
($stringx , $stringy) = $img->stringBounds("$string");
$img->moveTo($mleft+($gx/2)-($stringx/4),($height-$mbottom-2));
$img->string("$string");

$img->font('/usr/share/fonts/corefonts/georgia.ttf');
$img->fgcolor('blue');
$string = "$titel";
$string .= " - $subtitel" if $subtitel;
$string =~ s/\s+$//;
($stringx , $stringy) = $img->stringBounds("$string");
$img->moveTo(0,($mtop+10));
$img->string("$string");
$img->moveTo(0,($mtop+11));
$img->lineTo(-5+$stringx,$mtop+11);

$intro =~ s/\\n/ \\n /g;
$intro =~ s/[^\x00-\x7f]//g;
$intro =~ s/\r//g;
my @words = split / +/, $intro;
my $runy = $mtop+20;
while ( @words ) {
	$string = "";
	($stringx , $stringy) = $img->stringBounds(join(" ",$string,$words[0]));
	while ($stringx <= $mleft-5 && @words && $words[0] ne "\\n") {
		$string = join(" ",$string,shift @words);
		($stringx , $stringy) = $img->stringBounds(join(" ",$string,$words[0]));
	}
	shift @words if $words[0] eq "\\n";
	($stringx , $stringy) = $img->stringBounds("$string");
	$runy+=$stringy-1;
	$img->moveTo(0,$runy);
	$img->string("$string");
}

print $img->png;

exit;


