package Performance::Probability;

use 5.010;
use strict;
use warnings;
use Moo;

use Math::Cephes::Matrix;
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
    is       => 'rw',
);

has _l_k => (
    is       => 'rw',
);

sub _build__l_k {
	my $buy_matrix = Math::Cephes::Matrix->($self->bought_price);
        my $zero       = Math::Cepher::Matrix->($self->bought_price);
        $zero->clr(0);
  
}

has _p_k => (
    is       => 'rw',
);

sub _build__p_k {
	my $buy_matrix = Math::Cephes::Matrix->new($self->bought_price);
	my $payout_matrix = Math::Cephes::Matrix->new($self->payout);

        my $p_k = $buy_matrix->div($payout_matrix);

        return $p_k;
}

sub _mean_sigma_x {

}

sub _variance_sigma_x {

}

sub _covariance {

}

sub _correlation {

}

sub get_performance_probability {

}

1;
