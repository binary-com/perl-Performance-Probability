#Performance Probability test.
use 5.010;
use strict;
use warnings;

use Date::Utility;

my $file = 't/CR373909.csv';
open my $info, $file or die "Could not open $file: $!";

my $data;
my $cnt = 0;

my @buy;
my @payout;
my @start;
my @sell;
my @underlying;
my @type;

while (my $line = <$info>) {

    if ($cnt == 0) {
        $cnt++;
        next;
    }

    $data = $line;

    #tokenize contract data.
    my @tokens = split(/,/, $data);

    my $financial_market_bet_id = $tokens[2];
    my $bet_type                = $tokens[3];
    my $buy_price               = $tokens[4];
    my $payout_price            = $tokens[5];
    my $start_time              = $tokens[7];
    my $underlying_symbol       = $tokens[8];
    my $sell_time               = $tokens[11];

    my $dt_start_time = Date::Utility->new($start_time);
    my $dt_sell_time  = Date::Utility->new($sell_time);

    push @type,       $bet_type;
    push @buy,        $buy_price;
    push @payout,     $payout_price;
    push @start,      $dt_start_time;
    push @sell,       $dt_sell_time;
    push @underlying, $underlying_symbol;

}

my ($i, $j);
my @matrix;

for($i=0;$i<@start;++$i) {
        for($j=0;$j<@sell;++$j) {
                	if ($i != $j  and  $underlying[$i] eq $underlying[$j]) {
                        $matrix[$i][$j] = {};
                        #print "$i $j". $underlying[$i] ." == ". $underlying[$j] . "\n";

                        #check for time overlap.
                        my ($start_i, $start_j, $sell_i, $sell_j );
                        $start_i = $start[$i];
                        $start_j = $start[$j];
                        $sell_i  = $sell[$i];
                        $sell_j  = $sell[$j];

                        if ( $start_j->is_after($start_i) and $start_j->is_before($sell_i) ) {
                                #calculate a, b and c.
                                my $a = $start_j->epoch - $start_i->epoch;
                                my $b = $sell_i->epoch - $start_j->epoch;
                                my $c = $sell_j->epoch - $sell_i->epoch;

                                if ( $c<0 ) {
                                        $c = 0-$c ;
                                        $b = $sell_j->epoch - $start_i->epoch;
                                }

                                print "a: $a b: $b c: $c \n";

                                $matrix[$i][$j] = { a => $a, b => $b, c => $c };
                        	}

			} else {
                        #print "different underlying $i $j: ". $underlying[$i] ." != ". $underlying[$j]  ." \n";
                }
        }
}


close $info;

