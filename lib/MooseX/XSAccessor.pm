package MooseX::XSAccessor;

use 5.008;
use strict;
use warnings;

use Moose 2.0600 ();
use MooseX::XSAccessor::Trait::Attribute ();

BEGIN {
	$MooseX::XSAccessor::AUTHORITY = 'cpan:TOBYINK';
	$MooseX::XSAccessor::VERSION   = '0.000_01';
}

use Moose::Exporter;
"Moose::Exporter"->setup_import_methods;

sub init_meta
{
	shift;
	my %p = @_;
	Moose::Util::MetaRole::apply_metaroles(
		for             => $p{for_class},
		class_metaroles => {
			attribute => [qw( MooseX::XSAccessor::Trait::Attribute )],
		},
	);
}

1;

__END__

=pod

=for stopwords Auto-deref

=encoding utf-8

=head1 NAME

MooseX::XSAccessor - use Class::XSAccessor to speed up Moose accessors

=head1 SYNOPSIS

   package MyClass;
   
   use Moose;
   use MooseX::XSAccessor;
   
   has foo => (...);

=head1 DESCRIPTION

This module accelerates L<Moose>-generated accessor, reader, writer and
predicate methods using L<Class::XSAccessor>. You get a speed-up for no
extra effort. It is automatically applied to every attribute in the
class.

=begin private

=item init_meta

=end private


The use of the following features of Moose attributes prevents a reader
from being accelerated:

=over

=item *

Lazy builder or lazy default.

=item *

Auto-deref. (Does anybody use this anyway??)

=back

The use of the following features prevents a writer from being
accelerated:

=over

=item *

Type constraints (except C<Any>; C<Any> is effectively a no-op).

=item *

Triggers

=item *

Weak references

=back

An C<rw> accessor is effectively a reader and a writer glued together, so
both of the above lists apply.

=head1 HINTS

=over

=item *

Make attributes read-only when possible. This means that type constraints
and coercions will only apply to the constructor, not the accessors, enabling
the accessors to be accelerated.

=item *

If you do need a read-write attribute, consider making the main accessor
read-only, and having a separate writer method. (Like
L<MooseX::SemiAffordanceAccessor>.)

=item *

Make defaults eager instead of lazy when possible, allowing your readers
to be accelerated.

=item *

If you need to accelerate just a specific attribute, apply the attribute
trait directly:

   package MyClass;
   
   use Moose;
   
   has foo => (
      traits => ["MooseX::XSAccessor::Trait::Attribute"],
      ...,
   );

=back

=head1 CAVEATS

=over

=item *

Calling a writer method without a parameter in Moose does not raise an
exception:

   $person->set_name();    # sets name attribute to "undef"

However, this is a fatal error in Class::XSAccessor.

=item *

Class::XSAccessor predicate methods return false when the attribute tested
exists but is not defined. Standard Moose predicate methods return true in
this situation. See L<https://rt.cpan.org/Ticket/Display.html?id=86127>.

=item *

MooseX::XSAccessor does not play nice with attribute traits that alter
accessor behaviour, or define additional accessors for attributes.

=item *

MooseX::XSAccessor only works on blessed hashes; not e.g. L<MooseX::ArrayRef>
or L<MooseX::InsideOut>.

=back

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=MooseX-XSAccessor>.

=head1 SEE ALSO

L<MooseX::XSAccessor::Trait::Attribute>.

L<Moose>, L<Moo>, L<Class::XSAccessor>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2013 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

