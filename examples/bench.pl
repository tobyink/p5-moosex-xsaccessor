use strict;
use warnings;
use Benchmark qw(cmpthese);

{
	package Fast;
	use Moose;
	use MooseX::XSAccessor;
	has attr => (is => "ro");
	__PACKAGE__->meta->make_immutable;
}

{
	package Slow;
	use Moose;
	has attr => (is => "ro");
	__PACKAGE__->meta->make_immutable;
}

cmpthese(-1, {
	map {
		$_ => qq{ my \$o = $_->new(attr => 42); \$o->attr for 1..100 };
	} qw(Fast Slow)
});

__END__
       Rate Slow Fast
Slow 4654/s   -- -53%
Fast 9955/s 114%   --
