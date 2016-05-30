#Performance Probability test.
use 5.010;
use strict;
use warnings;

use Date::Utility;

use Test::Most;
use Test::FailWarnings;
use Test::More;

BEGIN {
# Temporary while testing if perl-Math-BivariateCDF can be build on travis.
    package Math::BivariateCDF;
    1;
    $INC{'Math/BivariateCDF.pm'} = 1;
}

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

close $info;

subtest 'performance_probability' => sub {

    #add test case inside here
    my $probability = 0.1;
    ok $probability, "Performance probability.";

    my $performance_probability_obj = Performance::Probability->new({
        payout       => \@payout,
        bought_price => \@buy,
        pnl          => 20000.0,
        type         => \@type,
        underlying   => \@underlying,
        start_time   => \@start,
        sell_time    => \@sell,
    });

    my $mean = $performance_probability_obj->_mean();
    ok $mean, "Mean in Performance probability calculation.";
};

done_testing;
