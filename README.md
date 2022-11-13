# NAME

Performance::Probability - The performance probability is a likelihood measure of a client reaching his/her current profit and loss.

# SYNOPSYS

    use Performance::Probability qw(get_performance_probability);

    my $probability = Performance::Probability::get_performance_probability(
                                     types        => [qw/CALL PUT/],
                                     payout       => [100, 100],
                                     bought_price => [75, 55],
                                     pnl          => 1000.0,
                                     underlying   => [qw/EURUSD EURUSD/],
                                     start_time   => [1461847439, 1461930839], #time in epoch
                                     sell_time    => [1461924960, 1461931561], #time in epoch
                                     );

# DESCRIPTION

The performance probability is a likelihood measure of a client reaching his/her current profit and loss.

## get\_shared\_winning\_probability

Calculate probability that a pair of digit contracts winning together.

The outcome of a digit contract pairs are correlated if they expire at same time( same digit).

The probability of a digit contract pair expiring at same digit is equal to the number of shared winning digits of the pair divied by 10.

Example:
i. The shared winning digits for a DIGITEVEN and a DIGITOVER 2 are: 4,6, and 8. The probability would be equal to 3/10.

ii. For a DIGITOVER 3 and a DIGITUNDER 9: 4,5,6,7, and 8. The probability would be equal to 5/10.

## get\_winning\_digits

Return the digits that contribute to a winning contract.

Example:DIGITEVEN : 0, 2, 4, 6, 8.
DIGITODD: 1, 3, 5,7,9

## get\_performance\_probability

Calculate performance probability ( modified sharpe ratio )
