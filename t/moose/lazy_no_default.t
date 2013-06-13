use lib "t/moose/lib";
use lib "moose/lib";
use lib "lib";

#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Fatal;

{
    package Foo;
    use MyMoose;

    ::like(
        ::exception{ has foo => (
                is   => 'ro',
                lazy => 1,
            );
            },
        qr/\QYou cannot have a lazy attribute (foo) without specifying a default value for it/,
        'lazy without a default or builder throws an error'
    );
}

done_testing;
