package Performance::Probability;

use 5.010;
use strict;
use warnings;
use Moo;

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

has _w_k => (
    is       => 'rw',
);

has _l_k => (
    is       => 'rw',
);

has _p_k => (
    is       => 'rw',
);

1;
