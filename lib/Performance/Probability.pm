package Performance::Probability;

use 5.010;
use strict;
use warnings;
use Moo;

use Math::Cephes::Matrix;
use Math::SymbolicX::Statistics::Distributions;
use Math::Vector::Real;#try this vector library.

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

#for vector replace math::cephes with math::vector::real.
sub _build__w_k {
	#my $payout_matrix = Math::Cephes::Matrix->new($self->payout);
	#my $buy_matrix    = Math::Cephes::Matrix->new($self->bought_price);

        #my $w_k = $payout->sub($buy_matrix);

        #return $w_k;
        
        my @w_k;

        for (0 .. $#@{$self->payout}) {
		my $tmp_w_k = $self->payout->[$_] - $self->bought_price->[$_];
		push @w_k, $tmp_w_k;
        }		

	return \@w_k;
}

has _l_k => (
    is       => 'rw',
);

sub _build__l_k {
	#my $buy_matrix = Math::Cephes::Matrix->new($self->bought_price);
        #my $zero       = Math::Cepher::Matrix->new($self->bought_price);
        #$zero->clr(0);
       
        #my $l_k = $zero->sub($buy_matrix);
	
	#return $l_k;  

        my @l_k;

	for ( 0 .. $#@{$self->bought_price}) {
		push @l_k, 0 - $self->bought_price->[$_];
	}

	return \@l_k;
}

has _p_k => (
    is       => 'rw',
);

sub _build__p_k {
	#my $buy_matrix = Math::Cephes::Matrix->new($self->bought_price);
	#my $payout_matrix = Math::Cephes::Matrix->new($self->payout);

        #my $p_k = $buy_matrix->div($payout_matrix);

        #return $p_k;

	my @p_k;

	for (0 .. $#@{$self->bought_price}) {
		my $tmp_pk = $self->payout_matrix->[$_] / $self->payout->[$_];
		push @p_k, $tmp_pk;
	}

	return \@p_k;
}

# sum( wk*pk + lk * (1-pk) )
sub _mean_sigma_x {
	
	#my $wk_pk = $self->_w_k->mul($self->_p_k);

        #my $one = ;

        #my $one_minus_pk = $one->sub($self->_p_k);

        #my $lk_pk = $self->_l_k->mul($self->one_minus_pk);	

	#my $tmp = $wk_pk->add($lk_pk);

	#sum all elements in $tmp.
	
	my @wk_pk;
	my @lk_pk;

	for (0 .. $#@{$self->_w_k}) {
		push @wk_pk, $self->_w_k->[$_] * $self->_p_k->[$_];
		push @lk_pk, $self->_l_k->[$_] * (1 - $self->_p_k->[$_]);
	}

        my $sum;

        for (0 .. $#@wk_pk) {
		$sum = $sum + ( @wk_pk[$_] + @lk_pk[$_] );
	}

	return $sum;
}

sub _variance_sigma_x {
   
       #my $wk_t = $self->_w_k->transp();
       #my $wk_square = $wk_t->mul($self->_w_k);
	
       #my $wk2_pk = $wk_square->mul($self->_p_k);

       #my $lk_t = $self->_l_k->transp();
       #my $lk_square = $lk_t->mul($self->_l_k);
       
       #my $lk2_pk = $lk_square->mul($self->_pk);

       my @wk_square;
       my @lk_square;

       my @wk_pk;
       my @lk_pk;

       for (0 .. $#@{$self->_w_k}) {
	       push @wk_square, $self->_w_k->[$_] * $self->_w_k->[$_];
               push @lk_square, $self->_l_k->[$_] * $self->_l_k->[$_];

	       push @wk_pk, $self->_w_k->[$_] * $self->_p_k->[$_];
	       push @lk_pk, $self->_l_k->[$_] * (1 - $self->_p_k->[$_]);
       }

       for (0 .. $#@wk_pk) {
               $self->_p_k->[$_] * @wk_square[$_];
	       $self->_p_k->[$_] * @lk_square[$_]; 
       }

             
}

sub _covariance {

}

sub _correlation {

}

sub get_performance_probability {

}

1;
