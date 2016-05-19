package Performance::Probability;

use 5.010;
use strict;
use warnings;
use Moo;

use Date::Utility;
use Math::BivariateCDF;
use Math::Gauss::XS;

our $VERSION = '0.01_1';

=head1 NAME

Performance::Probability - The performance probability is a likelihood measure of a client reaching his/her current P&L. 

=head1 VERSION

0.01_1

=head1 SYNOPSYS

=head1 DESCRIPTION

=cut

=head1 ATTRIBUTES

=head2 payout

Payout 

=cut

has payout => (
    is       => 'ro',
    required => 1,
);

=head2 bought_price

Bought price

=cut

has bought_price => (
    is       => 'ro',
    required => 1,
);

=head2 pnl

PnL

=cut

has pnl => (
    is       => 'ro',
    required => 1,
);

=head2 type

Type of contract. Call or Put.

=cut

has type => (
    is       => 'ro',
    required => 1,
);

=head2 underlying

Underlying asset

=cut

has underlying => (
    is       => 'ro',
    required => 1,
);

=head2 start_time

Contract's start time.

=cut

has start_time => (
    is       => 'ro',
    required => 1,
);

=head2 sell_time

Contract's sell time.

=cut

has sell_time => (
    is       => 'ro',
    required => 1,
);

=item B<_w_k>

Profit in case of winning. ( Payout minus bought price ).

=cut

has _wk => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build__wk',
);

sub _build__wk {
    my $self = shift;

    my @w_k;

    my $i;

    for ($i = 0; $i < @{$self->payout}; ++$i) {
        my $tmp_w_k = $self->payout->[$i] - $self->bought_price->[$i];
        push @w_k, $tmp_w_k;
    }

    return \@w_k;
}

=item B<_l_k>

Loss in case of losing. (Minus bought price).

=cut

has _lk => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build__lk',
);

sub _build__lk {
    my $self = shift;
    my @l_k;

    my $i;

    for ($i = 0; $i < @{$self->bought_price}; ++$i) {
        push @l_k, 0 - $self->bought_price->[$i];
    }

    return \@l_k;
}

=item B<_p_k>

Winning probability. ( Bought price / Payout ).

=cut

has _pk => (
    is      => 'rw',
    lazy    => 1,
    builder => '_build__pk',
);

sub _build__pk {
    my $self = shift;
    my @p_k;

    my $i;

    for ($i = 0; $i < @{$self->bought_price}; ++$i) {
        my $tmp_pk = $self->bought_price->[$i] / $self->payout->[$i];
        push @p_k, $tmp_pk;
    }

    return \@p_k;
}

=item B<_mean>

mean(sigma(x)) . x is profit and loss.

=cut

# sum( wk*pk + lk * (1-pk) )
sub _mean {
    my $self = shift;
    my @wk_pk;
    my @lk_pk;

    my $i;

    my $sum = 0;

    for ($i = 0; $i < @{$self->_wk}; ++$i) {
        push @wk_pk, $self->_wk->[$i] * $self->_pk->[$i];
        push @lk_pk, $self->_lk->[$i] * (1 - $self->_pk->[$i]);
    }

    for ($i = 0; $i < @wk_pk; ++$i) {
        $sum = $sum + ($wk_pk[$i] + $lk_pk[$i]);
    }

    return $sum;
}

=item B<_variance>

variance(sigma(x)) . x is profit and loss.

=cut

sub _variance {
    my $self = shift;
    my @wk_square;
    my @lk_square;

    my @wk_pk;
    my @lk_pk;

    my $sum = 0;

    my $i;

    for ($i = 0; $i < @{$self->_wk}; ++$i) {
        push @wk_square, $self->_wk->[$i] * $self->_wk->[$i];
        push @lk_square, $self->_lk->[$i] * $self->_lk->[$i];

        push @wk_pk, $self->_wk->[$i] * $self->_pk->[$i];
        push @lk_pk, $self->_lk->[$i] * (1 - $self->_pk->[$i]);
    }

    for ($i = 0; $i < @wk_pk; ++$i) {
        $sum = $sum + $self->_pk->[$i] * $wk_square[$i];
        $sum = $sum + $self->_lk->[$i] * $lk_square[$i];

        $sum = $sum - $wk_pk[$i] + $lk_pk[$i];
    }

    return $sum;
}

=item B<_covariance>



=cut

sub _covariance {
    my $self = shift;

    my ($i, $j);
    my $covariance = 0;

    for ($i = 0; $i < @{$self->start_time}; ++$i) {
        for ($j = 0; $j < @{$self->sell_time}; ++$j) {
            if ($i != $j and $self->underlying->[$i] eq $self->underlying->[$j]) {

                #check for time overlap.
                my ($start_i, $start_j, $sell_i, $sell_j);
                $start_i = $self->start_time->[$i];
                $start_j = $self->start_time->[$j];
                $sell_i  = $self->sell_time->[$i];
                $sell_j  = $self->sell_time->[$j];

                if ($start_j->is_after($start_i) and $start_j->is_before($sell_i)) {
                    #calculate a, b and c.
                    my $a = $start_j->epoch - $start_i->epoch;
                    my $b = $sell_i->epoch - $start_j->epoch;
                    my $c = $sell_j->epoch - $sell_i->epoch;

                    if ($c < 0) {
                        $c = 0 - $c;
                        $b = $sell_j->epoch - $start_i->epoch;
                    }

                    my $i_strike = Math::Gauss::XS::inv_cdf($self->_pk->[$i]);
                    my $j_strike = Math::Gauss::XS::inv_cdf($self->_pk->[$j]);

                    my $corr_ij = $b / (sqrt($a + $b) * sqrt($b + $c));

                    my $p_ij = Math::BivariateCDF::bivnor($i_strike, $j_strike, $corr_ij);

                    my $covariance_ij =
                        ($p_ij - $self->_pk->[$i] * $self->_pk->[$j]) * ($self->_wk->[$i] - $self->_lk->[$i]) * ($self->_wk->[$j] - $self->_lk->[$j]);

                    $covariance = $covariance + $covariance_ij;

                    print "$i $j pi: " . $self->_pk->[$i] . " pj: " . $self->_pk->[$j] . " $i_strike $j_strike $corr_ij $p_ij $covariance_ij\n";

                }
            }
        }
    }

    return $covariance;
}

sub get_performance_probability {

}

1;
