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

sub _build__w_k {
	my $payout_matrix = Math::Cephes::Matrix->new($self->payout);
	my $buy_matrix    = Math::Cephes::Matrix->new($self->buy_matrix);

        my $w_k = $payout->sub($buy_matrix);

        return $w_k;
}

has _l_k => (
    is       => 'rw',
);

sub _build__l_k {
	my $buy_matrix = Math::Cephes::Matrix->new($self->bought_price);
        my $zero       = Math::Cepher::Matrix->new($self->bought_price);
        $zero->clr(0);
       
        my $l_k = $zero->sub($buy_matrix);
	
	return $l_k;  
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

# sum( wk*pk + lk * (1-pk) )
sub _mean_sigma_x {
	
	my $wk_pk = $self->_w_k->mul($self->_p_k);

        my $one = ;

        my $one_minus_pk = $one->sub($self->_p_k);

        my $lk_pk = $self->_l_k->mul($self->one_minus_pk);	

	my $tmp = $wk_pk->add($lk_pk);

	#sum all elements in $tmp.
	
}

sub _variance_sigma_x {
   
       my $wk_t = $self->_w_k->transp();
       my $wk_square = $wk_t->mul($self->_w_k);
	
       my $wk2_pk = $wk_square->mul($self->_p_k);

       
}

sub _covariance {

}

sub _correlation {

}

sub get_performance_probability {

}

1;
