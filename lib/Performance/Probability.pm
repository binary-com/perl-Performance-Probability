package Performance::Probability;

use 5.010;
use strict;
use warnings;
use Moo;

use Date::Utility;

our $VERSION = '0.01';

=head1 NAME

Performance::Probability - The performance probability is a likelihood measure of a client reaching his/her current P&L. 

=head1 VERSION

0.01

=head1 SYNOPSYS

=head1 DESCRIPTION

=cut

has payout => (
    is       => 'ro',
    required => 1,
);

has bought_price => (
    is       => 'ro',
    required => 1,
);

has pnl => (
    is       => 'ro',
    required => 1,
);

has type => (
    is       => 'ro',
    required => 1,
);

has underlying => (
    is       => 'ro',
    required => 1,
);

has start_time => (
    is       => 'ro',
    required => 1,
);

has sell_time => (
    is       => 'ro',
    required => 1,
);

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

has _p_k => (
    is => 'rw',
);

sub _build__p_k {
    my $self = shift;
    my @p_k;

    my $i;

    for ($i = 0; $i < @{$self->bought_price}; ++$i) {
        my $tmp_pk = $self->payout_matrix->[$i] / $self->payout->[$i];
        push @p_k, $tmp_pk;
    }

    return \@p_k;
}

# sum( wk*pk + lk * (1-pk) )
sub _mean_sigma_x {
    my $self = shift;
    my @wk_pk;
    my @lk_pk;

    my $i;

    for ($i = 0; $i < @{$self->_w_k}; ++$i) {
        push @wk_pk, $self->_w_k->[$i] * $self->_p_k->[$i];
        push @lk_pk, $self->_l_k->[$i] * (1 - $self->_p_k->[$i]);
    }

    my $sum;

    for ($i = 0; $i < @wk_pk; ++$i) {
        $sum = $sum + ($wk_pk[$i] + $lk_pk[$i]);
    }

    return $sum;
}

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

sub _covariance {
    return 0.0;
}

#only use for dev. will be replace with the real one.
sub _dummy_bivar {
    return 0.01;
}

sub get_performance_probability {

}

sub BUILDARGS {
    my ($class, %args) = @_;

    return \%args;
}

1;
