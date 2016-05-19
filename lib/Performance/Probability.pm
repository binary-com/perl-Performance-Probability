package Performance::Probability;

use 5.010;
use strict;
use warnings;
use Moo;

use Date::Utility;
use Math::BivariateCDF;

our $VERSION = '0.01';

=head1 NAME

Performance::Probability - The performance probability is a likelihood measure of a client reaching his/her current P&L. 

=head1 VERSION

0.01

=head1 SYNOPSYS

=head1 DESCRIPTION

=cut

=item B<payout>

Payout

=cut

has payout => (
    is       => 'ro',
    required => 1,
);

=item B<bought_price>

Bought price

=cut

has bought_price => (
    is       => 'ro',
    required => 1,
);

=item B<pnl>

PnL

=cut

has pnl => (
    is       => 'ro',
    required => 1,
);

=item B<type>

Contract type: Call or Put.

=cut

has type => (
    is       => 'ro',
    required => 1,
);

=item B<underlying>

Contract's underlying

=cut

has underlying => (
    is       => 'ro',
    required => 1,
);

=item B<start_time>

Contract's start time

=cut

has start_time => (
    is       => 'ro',
    required => 1,
);

=item B<sell_time>

Contract's sell time

=cut

has sell_time => (
    is       => 'ro',
    required => 1,
);

=item B<_w_k>

Profit in case of winning. ( Payout minus bought price ).

=cut

has _w_k => (
    is => 'rw',
);

sub _build__w_k {
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

has _l_k => (
    is => 'rw',
);

sub _build__l_k {
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

has _p_k => (
    is => 'rw',
);

sub _build__p_k {
    my $self = shift;
    my @p_k;

    my $i;

    for ($i = 0; $i < @{$self->bought_price}; ++$i) {
        my $tmp_pk = $self->bought_price->[$i] / $self->payout->[$i];
        push @p_k, $tmp_pk;
    }

    return \@p_k;
}

=item B<_mean_sigma_x>

mean(sigma(x)) . x is profit and loss.

=cut

# sum( wk*pk + lk * (1-pk) )
sub _mean_sigma_x {
    my $self = shift;
    my @wk_pk;
    my @lk_pk;

    my $i;

    my $sum;

    for ($i = 0; $i < @{$self->_w_k}; ++$i) {
        push @wk_pk, $self->_w_k->[$i] * $self->_p_k->[$i];
        push @lk_pk, $self->_l_k->[$i] * (1 - $self->_p_k->[$i]);
    }

    for ($i = 0; $i < @wk_pk; ++$i) {
        $sum = $sum + ($wk_pk[$i] + $lk_pk[$i]);
    }

    return $sum;
}

=item B<_variance_sigma_x>

variance(sigma(x)) . x is profit and loss.

=cut

sub _variance_sigma_x {
    my $self = shift;
    my @wk_square;
    my @lk_square;

    my @wk_pk;
    my @lk_pk;

    my $sum;

    my $i;

    for ($i = 0; $i < @{$self->_w_k}; ++$i) {
        push @wk_square, $self->_w_k->[$i] * $self->_w_k->[$i];
        push @lk_square, $self->_l_k->[$i] * $self->_l_k->[$i];

        push @wk_pk, $self->_w_k->[$i] * $self->_p_k->[$i];
        push @lk_pk, $self->_l_k->[$i] * (1 - $self->_p_k->[$i]);
    }

    for ($i = 0; $i < @wk_pk; ++$i) {
        $sum = $sum + $self->_p_k->[$i] * $wk_square[$i];
        $sum = $sum + $self->_l_k->[$i] * $lk_square[$i];

        $sum = $sum - $wk_pk[$i] + $lk_pk[$i];
    }

    return $sum;
}

sub _correlation {
    my $self = shift;

    my ($i, $j);
    my @matrix;

    for ($i = 0; $i < @{$self->start_time}; ++$i) {
        for ($j = 0; $j < @{$self->sell_time}; ++$j) {
            if ($i != $j and $self->underlying->[$i] eq $self->underlying->[$j]) {
                $matrix[$i][$j] = {};
                #print "$i $j". $underlying[$i] ." == ". $underlying[$j] . "\n";

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

                    print "$i $j     a: $a b: $b c: $c \n";

                    $matrix[$i][$j] = {
                        a => $a,
                        b => $b,
                        c => $c
                    };
                }
            } else {
                #print "different underlying $i $j: ". $underlying[$i] ." != ". $underlying[$j]  ." \n";
            }
        }
    }
    #dummy value. replace with calculated value
    return 0.01;
}

sub _covariance {

}

sub get_performance_probability {

}

sub BUILDARGS {
    my ($class, %args) = @_;

    return \%args;
}

1;
