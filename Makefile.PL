use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'Performance::Probability',
    AUTHOR           => q{Binary.com <support@binary.com>},
    VERSION_FROM     => 'lib/Performance/Probability.pm',
    ABSTRACT_FROM    => 'lib/Performance/Probability.pm',
    LICENSE          => 'artistic_2',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    TEST_REQUIRES => {
        'Test::More'          => 0,
        'Test::Most'          => 0,
        'Test::FailWarnings', => 0,
        'Test::Perl::Critic', => 0,
    },
    PREREQ_PM => {
        'Math::Gauss::XS'    => 0,
        'Math::BivariateCDF' => 0,
        'Machine::Epsilon'   => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'Performance-Probability-*' },
);
