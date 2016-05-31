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

Performance::Probability - The performance probability is a likelihood measure of a client reaching his/her current profit and loss. 

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

Profit & Loss

=cut

has pnl => (
    is       => 'ro',
    required => 1,
);

=head2 type

Type of contract. Call or Put. For now, we only consider call and put contracts. We may consider
other type of binary option contracts in the future.

=cut

has types => (
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

#Profit in case of winning. ( Payout minus bought price ).

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

#Loss in case of losing. (Minus bought price).

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

#Winning probability. ( Bought price / Payout ).

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

#Sigma( profit * winning probability + loss * losing probability ).

sub _mean {
    my $self = shift;

    my $i;
    my $sum = 0;

    for ($i = 0; $i < @{$self->_wk}; ++$i) {

        $sum = $sum + ($self->_wk->[$i] * $self->_pk->[$i]) + ($self->_lk->[$i] * (1 - $self->_pk->[$i]));
    }

    return $sum;
}

#Sigma( (profit**2) * winning probability + (loss**2) * losing probability ).

sub _variance_x_square {
    my $self = shift;

    my $sum = 0;
    my $i;

    for ($i = 0; $i < @{$self->_wk}; ++$i) {
        $sum = $sum + (($self->_wk->[$i]**2) * $self->_pk->[$i]) + (($self->_lk->[$i]**2) * (1 - $self->_pk->[$i]));
    }

    return $sum;
}

#Sum of Covariance(i,j). See the documentation for the details.
#Covariance(i, j) is the covariance between contract i and j with time overlap.

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
                    #calculate a, b and c interval. please see the documentation for details
                    #of a, b and c.
                    my $a_interval = $start_j->epoch - $start_i->epoch;
                    my $b_interval = $sell_i->epoch - $start_j->epoch;
                    my $c_interval = $sell_j->epoch - $sell_i->epoch;

                    if ($c_interval < 0) {
                        $c_interval = 0 - $c_interval;
                        $b_interval = $sell_j->epoch - $start_i->epoch;
                    }

                    my $i_strike = 0.0 - Math::Gauss::XS::inv_cdf($self->_pk->[$i]);
                    my $j_strike = 0.0 - Math::Gauss::XS::inv_cdf($self->_pk->[$j]);

                    my $corr_ij = $b_interval / (sqrt($a_interval + $b_interval) * sqrt($b_interval + $c_interval));

                    if ($self->types->[$i] ne $self->types->[$j]) {
                        $corr_ij = -1 * $corr_ij;
                    }

                    my $p_ij = Math::BivariateCDF::bivnor($i_strike, $j_strike, $corr_ij);

                    my $covariance_ij =
                        ($p_ij - $self->_pk->[$i] * $self->_pk->[$j]) * ($self->_wk->[$i] - $self->_lk->[$i]) * ($self->_wk->[$j] - $self->_lk->[$j]);

                    $covariance = $covariance + $covariance_ij;
                }
            }
        }
    }

    return $covariance;
}

=item B<get_performance_probability>

Calculate performance probability ( modified sharpe ratio );

=cut

sub get_performance_probability {
    my $self = shift;

    my $prob = 0;

    my $mean = $self->_mean();

    $prob = $self->pnl - $mean;
    $prob = $prob / sqrt(($self->_variance_x_square() - ($mean**2.0)) + 2.0 * $self->_covariance());

    $prob = 1.0 - Math::Gauss::XS::cdf($prob, 0.0, 1.0);

    return $prob;
}

1;
