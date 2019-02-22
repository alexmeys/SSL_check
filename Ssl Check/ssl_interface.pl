#!/usr/bin/perl
#Alex Meys

#===================================*/
use Tk;
use Tk::Table;

require "ssl_motor.pl";


my $o = 0;
my $p = 0;
my ($klantnm, $issuer, $start, $eind, $nog) = &motor();
my @klanten = @$klantnm;
my @verdeler = @$issuer;
my @startdatum = @$start;
my @einddatum = @$eind;
my @tegaan = @$nog;
my $totalo = $#klanten+1;

my $mw = MainWindow->new;
$mw->geometry("1120x600");
$mw->resizable(0,0);
$mw->title("SSL Status Checker");


my $table_frame = $mw->Frame(-width => 1120, -height=> 550)->pack(-expand => 1, -side => 'top');
$table_frame->packPropagate(0);
my $table = $table_frame->Table(-columns => 5,
								-rows => $totalo,
								-fixedrows => 1,
								-scrollbars => 'oeos',
								-relief => 'raised')->pack(-fill => 'both', -expand => 1, -side => 'top');

my $col = 1;
my $tmp_label0 = $table->Label(-text => "Record", -width => 5, -relief =>'raised');
$table->put(0, $col, $tmp_label0);
$col+=1;
my $tmp_label1 = $table->Label(-text => "Registratie ", -width => 5, -relief =>'raised');
$table->put(0, $col, $tmp_label1);
$col+=1;
my $tmp_label2 = $table->Label(-text => "Vervaldatum ", -width => 5, -relief =>'raised');
$table->put(0, $col, $tmp_label2);
$col+=1;
my $tmp_label3 = $table->Label(-text => "Uitgever ", -width => 5, -relief =>'raised');
$table->put(0, $col, $tmp_label3);
$col+=1;
my $tmp_label4 = $table->Label(-text => "Dagen", -width => 5, -relief =>'raised');
$table->put(0, $col, $tmp_label4);

  
foreach my $row (1 .. $totalo)
{
  my $col = 1;
  foreach my $client (@klanten)
  {
    my $tmp_label = $table->Label(-text => "$klanten[$o]",
                                  -padx => 5,
                                  -anchor => 'w',
                                  -background => 'white',
                                  -relief => "groove",
								  -width => 40);
								  $tmp_label->packPropagate(0);
    $table->put($row, $col, $tmp_label);
  }
  my $col = 2;
  foreach my $startd (@startdatum)
  {
    my $tmp_label2 = $table->Label(-text => "$startdatum[$o]",
                                  -padx => 5,
                                  -anchor => 'w',
                                  -background => 'white',
                                  -relief => "groove");
    $table->put($row, $col, $tmp_label2);
  }
  my $col = 3;
  foreach my $eindd (@einddatum)
  {
    my $tmp_label3 = $table->Label(-text => "$einddatum[$o]",
                                  -padx => 5,
                                  -anchor => 'w',
                                  -background => 'white',
                                  -relief => "groove");
    $table->put($row, $col, $tmp_label3);
  }
  my $col = 4;
  foreach my $verdelers (@verdeler)
  {
    my $tmp_label4 = $table->Label(-text => "$verdeler[$o]",
                                  -padx => 5,
                                  -anchor => 'w',
                                  -background => 'white',
                                  -relief => "groove",
								  -width => 40);
								  $tmp_label4->packPropagate(0);
    $table->put($row, $col, $tmp_label4);
  }
  my $col = 5;
  foreach my $dagen (@tegaan)
  {
    my $tmp_label5 = $table->Label(-text => "$tegaan[$o]",
                                  -padx => 5,
                                  -anchor => 'w',
                                  -background => 'white',
                                  -relief => "groove");
    $table->put($row, $col, $tmp_label5);
  }
  $o++;
}
$table->pack();

my $button_frame2 = $mw->Frame( -borderwidth => 5 )->pack(-side => 'left', -expand => 1);
$button_frame2->Button(-text => "Mail", -command => \&sendme)->pack(-expand => 1, -ipadx => 60);

my $button_frame1 = $mw->Frame( -borderwidth => 5 )->pack(-side => 'left', -expand => 1);
$button_frame1->Button(-text => "Export Excel", -command => \&exp)->pack(-expand => 1, -ipadx => 60);

my $button_frame0 = $mw->Frame( -borderwidth => 5 )->pack(-side => 'left', -expand => 1);
$button_frame0->Button(-text=>"Over", -command => \&over)->pack(-expand => 1, -ipadx => 60);

my $button_frame = $mw->Frame( -borderwidth => 5 )->pack(-side => 'right', -expand => 1);
$button_frame->Button(-text => "Exit", -command => \&kill)->pack(-expand => 1, -ipadx => 60);

MainLoop;

sub over
{
  	my $response = $mw -> messageBox(-message=>"Gemaakt door:\nAlex Meys, 2012",-type=>'ok',-icon=>'info');
}
sub kill
{
  POSIX::_exit(0);
}
