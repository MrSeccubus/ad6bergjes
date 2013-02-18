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
$titel = "" if $nick eq "total";

my @hoogtes = (
		724,725,744,797,848,900,950,994,1031,1067,1108,1150,1190,1225,1266,1310,1354,1390,1437,1478,1512,1533,1565,1637,1682,1723,1764,1795,1814,1815
		);
my $startat = 700;
my $stopat = 1900;


#die join "\n", GD::Simple->color_names;

print $query->header("image/png");
my $width = $query->param("width");
my $height = $query->param("height");

$width += 0;
$height += 0;
$width = 200 unless $width;
$height = 80 if $height < 80;

$percent += 0;
$percent = 101 if $percent > 100;
$percent = 0 if $percent < 0;

# O.K. lets do some math
# Drawing area
my $gx = $width-10;
my $gy = $height-10;
# Pixel per meter
my $mpp = ($stopat-$startat)/$gy;
# Stop at pixel
my $percentx = ($gx * $percent / 100) + 5;
$percentx = 8 if ( $percent > 0 and $percentx <8);
# Pixel per step
my $perstep = $gx / (@hoogtes - 1);

# Start drawing
my $img = GD::Simple->new($width,$height);
$img->penSize(1,1);
$img->bgcolor('transparent');
$img->fgcolor('transparent');
$img->rectangle(0,0,$width,$height);

$img->bgcolor(156,105,29);
$img->fgcolor(156,105,29);
my $x = 5;
my $current = shift @hoogtes;
$current -= $startat;
while ( @hoogtes ) {
	if ( $x < $percentx ) {
		$img->fgcolor('white');
	} else {
		$img->fgcolor(156,105,29);
	}

	my $previous = $current;
	$current = shift @hoogtes;
	$current -= $startat;
	my $y = $previous / $mpp;
	my $upperstep = ($current-$previous) / ($perstep -1 );
	$img->moveTo($x,$height-5);
	my $y = $previous/$mpp;
	$img->lineTo($x,$height-(5+$y));
	for my $tx ( $x+1..$x+$perstep-1 ) {
		if ( $tx < $percentx ) {
			$img->fgcolor('black');
		} else {
			$img->fgcolor('white');
		}
		$img->moveTo($tx,$height-(5+$y));
		$img->lineTo($tx,$height-(4+$y));
		if ( $tx < $percentx ) {
			$img->fgcolor('white');
		} else {
			$img->fgcolor(156,105,29);
		}
		$y += ($upperstep/$mpp);
		$img->moveTo($tx,$height-5);
		$img->lineTo($tx,$height-(3+$y));
	}
	$x += $perstep;
}

#$img->bgcolor('red');
#$img->fgcolor('white');
$img->fgcolor('black');
$img->font('/usr/share/fonts/corefonts/georgiab.ttf');
$img->fontsize(12);
my ($stringx , $stringy) = $img->stringBounds("$titel");
$img->moveTo(($width/2)-($stringx/4),($height-18));
$img->string("$titel");

my $string;
if ( $in >= 1000 ) {
	my $mille = int($in/1000);
	my $rest = $in - (1000 * $mille);
	$string = sprintf("\xE2\x82\xAC %d.%03d (%d%)", $mille, $rest, $percent);
} else {
	$string = sprintf("\xE2\x82\xAC %d (%d%)", $in, $percent);
}
($stringx , $stringy) = $img->stringBounds("$string");
$img->moveTo(($width/2)-($stringx/4),($height-7));
$img->string("$string");

print $img->png;

exit;


