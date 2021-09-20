#!/usr/local/bin/perl
#Alex Meys
#===================================*/
use warnings;
use strict;
use Net::SSLeay;
use Date::Parse;
use Date::Calc qw/Delta_YMD Delta_Days/;
use Spreadsheet::WriteExcel;
use Net::SMTP;

open(BEST, "<links.txt");
my @url = <BEST>;
close(BEST);
my $i=0;
my @cklnaam;
my @cissue;
my @cvan;
my @ctot;
my @left;

sub motor{
#Nu tijd
my $now = localtime;
my ($ss,$mm,$hh,$day,$month,$year,$zone) = strptime($now);
$year+=1900;
$month+=1;
if($month <= 9)
{
  $month = "0$month";
}
else{$month = $month;}
if($day <= 9)
{
  $day = "0$day";
}else{$day = $day;}

foreach(@url)
{
chomp(@url);
(undef, undef, undef, my $certi) = &Net::SSLeay::get_https3($url[$i], 443, '/');

if ($certi) {
my $name = Net::SSLeay::X509_NAME_oneline(Net::SSLeay::X509_get_subject_name($certi));

if($name =~ m/CN=(.*)/)
{
  my $val = $&;
  chomp($val);
  $val = substr($val, 3);
  push(@cklnaam, $val);
}
else
{
  push(@cklnaam, $name);
}
my $issued = Net::SSLeay::X509_NAME_oneline(Net::SSLeay::X509_get_issuer_name($certi));

if($issued =~ m/CN=(.*)/)
{
  my $val = $&;
  chomp($val);
  $val = substr($val, 3);
  push(@cissue, $val);
}
else
{
  push(@cissue, $issued);
}
my $van = Net::SSLeay::X509_get_notBefore($certi);
push (@cvan, Net::SSLeay::P_ASN1_UTCTIME_put2string($van));

my $tot = Net::SSLeay::X509_get_notAfter($certi);
push(@ctot, Net::SSLeay::P_ASN1_UTCTIME_put2string($tot));

  my ($ss2,$mm2,$hh2,$day2,$month2,$year2,$zone2) = strptime($ctot[$i]);
  $year2+=1900;
  $month2+=1;
  if($month2 <= 9)
  {
    $month2 = "0$month2";
  }
  else{$month2 = $month2;}
  if($day2 <= 9)
  {
    $day2 = "0$day";
  }else{$day2 = $day2;}
  my $delta = Delta_Days($year,$month,$day,  $year2, $month2, $day2);
  push(@left, $delta);

} else
{
  push(@cklnaam, "$url[$i]");
  push(@cissue, "Niet bereikbaar,");
  push(@cvan, "poort 443?");
  push(@ctot, "Server eruit?");
  push(@left, 700);
}
$i++;
}
return(\@cklnaam, \@cissue, \@cvan, \@ctot, \@left);
}

sub exp
{  
  my $z = 1;
  my $w = 0;
  my $y = 0;
  
  my $book = Spreadsheet::WriteExcel->new("C:\\test.xls");
  my $sheet = $book->add_worksheet("SSL Gegevens");
  my $opmaak = $book->add_format();
  $opmaak->set_color('blue');
  $opmaak->set_align('center');
  my $opmaak2 = $book->add_format();
  $opmaak2->set_align('left');
  
  $sheet->write(0, 0, "Record", $opmaak);
  $sheet->write(0, 1, "Registratie", $opmaak);
  $sheet->write(0, 2, "Verval datum", $opmaak);
  $sheet->write(0, 3, "Uitgever", $opmaak);
  $sheet->write(0, 4, "Dagen", $opmaak);
  foreach my $line (@cklnaam)
  {
    $sheet->write($z, $w, "$cklnaam[$y]", $opmaak2);
	$y+=1;
	$z +=1;
  }
  $y=0;
  $z=1;
  $w=1;
  foreach my $lines (@cissue)
  {
    $sheet->write($z, $w, "$cissue[$y]", $opmaak2);
	$y+=1;
	$z +=1;
  }
  $y=0;
  $z=1;
  $w=2;
  foreach my $ln (@cvan)
  {
    $sheet->write($z, $w, "$cvan[$y]", $opmaak2);
	$y+=1;
	$z +=1;
  }
  $y=0;
  $z=1;
  $w=3;
  foreach my $li (@ctot)
  {
    $sheet->write($z, $w, "$ctot[$y]", $opmaak2);
	$y+=1;
	$z +=1;
  }
  $y=0;
  $z=1;
  $w=4;
  foreach my $lin (@left)
  {
    $sheet->write($z, $w, "$left[$y]", $opmaak2);
	$y+=1;
	$z +=1;
  }
  $y=0;
  $w=0;
  $z=1;
  $book->close();
}

sub sendme
{
  my (@amail, @bmail, @cmail, @dmail, @fmail);
  for(my $t=0; $t <= $#cklnaam; $t++)
  {
    if($left[$t] < 32) #32 dagen, om de certs op eerste vd maand mee op te vangen.
	{
	  push (@amail, $left[$t]);
	  push (@bmail, $cklnaam[$t]);
	  push (@cmail, $cissue[$t]);
	  push (@dmail, $cvan[$t]);
	  push (@fmail, $ctot[$t]);
	}
	else{;};
  }

  my ($naar, $van, $onderwerp, $bericht, $host);
  my $zend = "uit.base.be"; #Uitgaande mailserver is variabel naargelang ISP.
  $van = "stel\@uwafzender.in"; #Fancy mailadres (sslmonitor@bedrijfsnaam.be?)
  $naar = "stel\@uwcontact.in"; #hieronder aantal adressen (iedereen krijgt een mail met 1 aan persoon, andere kunnen niet zien wie deze nog krijgt.
  my $naar1 = "stel\@uwcontacten.in";
  my $naar2 = "stel\@uwcontacten.in";
  my $naar3 = "stel\@uwcontacten.in";
  my $smtp = Net::SMTP->new("$zend", Timeout => 50);
  my $verb = $smtp->domain;
  
  $smtp->mail($van);
  $smtp->to($naar, $naar1, $naar2, $naar3);
  $smtp->data();
  
  $smtp->datasend("From: $van\n");
  $smtp->datasend("To: $naar\n");
  $smtp->datasend("Subject: SSL rapport, te doen deze maand\n");
  $smtp->datasend("Priority: Urgent\n");
  $smtp->datasend("\n");
  $smtp->datasend("Beste,\n\nHieronder de certificaten die vervallen of niet in orde zijn van deze maand:\n\n");
  my $max = $#amail;
  for(my $s=0; $s <= $max ; $s++)
  {
    $smtp->datasend("Url: ".$bmail[$s]. "\nDagen: ".$amail[$s]. "\nAankoop: ". $cmail[$s]. "\nBegin: ".$dmail[$s]. "\nEind: ".$fmail[$s]."\n\n");
  }
  $smtp->datasend("Steeds tot uw dienst.\n\nMet vriendelijke groet,\n\nAlex Meys");
  $smtp->dataend();
  $smtp->quit;
}
1;
