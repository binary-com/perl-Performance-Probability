#!perl -T
use 5.010;
use strict;
use warnings;

use Test::More;

plan tests => 1;

use_ok( 'Performance::Probability' ) || print "Bail out!\n";

diag( "Testing Performance::Probability $Performance::Probability::VERSION, Perl $], $^X" );
