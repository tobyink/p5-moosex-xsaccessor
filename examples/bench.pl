use strict;
use warnings;
use Benchmark qw(cmpthese);

{
	package Fast;
	use Moose;
	use MooseX::XSAccessor;
	has attr => (is => "ro", isa => "Any");
	__PACKAGE__->meta->make_immutable;
}

{
	package Slow;
	use Moose;
	has attr => (is => "ro", isa => "Any");
	__PACKAGE__->meta->make_immutable;
}

cmpthese(-1, {
	map {
		$_ => qq{ my \$o = $_->new(attr => 42); \$o->attr for 1..100 };
	} qw(Fast Slow)
});

__END__
        Rate Slow Fast
Slow  4403/s   -- -57%
Fast 10142/s 130%   --
