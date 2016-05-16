package Performance::Probability;

use 5.010;
use strict;
use warnings;
use Moo;

use Math::SymbolicX::Statistics::Distributions;

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

has _w_k => (
    is => 'rw',
);

sub _build__w_k {
    my @w_k;

    for (0 .. $# @{$self->payout}) {
        my $tmp_w_k = $self->payout->[$_] - $self->bought_price->[$_];
        push @w_k, $tmp_w_k;
    }

    return \@w_k;
}

has _l_k => (
    is => 'rw',
);

sub _build__l_k {
    my @l_k;

    for (0 .. $# @{$self->bought_price}) {
        push @l_k, 0 - $self->bought_price->[$_];
    }

    return \@l_k;
}

has _p_k => (
    is => 'rw',
);

sub _build__p_k {
    my @p_k;

    for (0 .. $# @{$self->bought_price}) {
        my $tmp_pk = $self->payout_matrix->[$_] / $self->payout->[$_];
        push @p_k, $tmp_pk;
    }

    return \@p_k;
}

# sum( wk*pk + lk * (1-pk) )
sub _mean_sigma_x {
    my @wk_pk;
    my @lk_pk;

    for (0 .. $# @{$self->_w_k}) {
        push @wk_pk, $self->_w_k->[$_] * $self->_p_k->[$_];
        push @lk_pk, $self->_l_k->[$_] * (1 - $self->_p_k->[$_]);
    }

    my $sum;

    for (0 .. $#@wk_pk) {
        $sum = $sum + (@wk_pk[$_] + @lk_pk[$_]);
    }

    return $sum;
}

sub _variance_sigma_x {
    my @wk_square;
    my @lk_square;

    my @wk_pk;
    my @lk_pk;

    my $sum;

    for (0 .. $# @{$self->_w_k}) {
        push @wk_square, $self->_w_k->[$_] * $self->_w_k->[$_];
        push @lk_square, $self->_l_k->[$_] * $self->_l_k->[$_];

        push @wk_pk, $self->_w_k->[$_] * $self->_p_k->[$_];
        push @lk_pk, $self->_l_k->[$_] * (1 - $self->_p_k->[$_]);
    }

    for (0 .. $#@wk_pk) {
        $sum = $sum + $self->_p_k->[$_] * @wk_square[$_];
        $sum = $sum + $self->_l_k->[$_] * @lk_square[$_];

	$sum = $sum - @wk_pk[$_] + @lk-pk[$_];
    }

    return $sum;
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
