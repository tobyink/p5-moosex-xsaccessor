package MooseX::XSAccessor::Trait::Attribute;

use 5.008;
use strict;
use warnings;

use Class::XSAccessor 1.16 ();
use Scalar::Util qw(reftype);
use B qw(perlstring);

BEGIN {
	$MooseX::XSAccessor::Trait::Attribute::AUTHORITY = 'cpan:TOBYINK';
	$MooseX::XSAccessor::Trait::Attribute::VERSION   = '0.001';
}

# Map Moose terminology to Class::XSAccessor options.
my %class_xsaccessor_opt = (
	accessor   => "accessors",
	reader     => "getters",
	writer     => "setters",
	predicate  => "predicates",
);

use Moose::Role;

sub accessor_is_simple
{
	my $self = shift;
	return !!0 if $self->has_type_constraint && $self->type_constraint ne "Any";
	return !!0 if $self->should_coerce;
	return !!0 if $self->has_trigger;
	return !!0 if $self->is_weak_ref;
	return !!0 if $self->is_lazy;
	return !!0 if $self->should_auto_deref;
	!!1;
}

sub reader_is_simple
{
	my $self = shift;
	return !!0 if $self->is_lazy;
	return !!0 if $self->should_auto_deref;
	!!1;
}

sub writer_is_simple
{
	my $self = shift;
	return !!0 if $self->has_type_constraint && $self->type_constraint ne "Any";
	return !!0 if $self->should_coerce;
	return !!0 if $self->has_trigger;
	return !!0 if $self->is_weak_ref;
	!!1;
}

sub predicate_is_simple
{
	my $self = shift;
	!!1;
}

# Class::XSAccessor doesn't do clearers
sub clearer_is_simple
{
	!!0;
}

override install_accessors => sub {
	my $self = shift;
	my ($inline) = @_;
	
	my $class     = $self->associated_class;
	my $classname = $class->name;
	my $is_hash   = reftype($class->get_meta_instance->create_instance) eq q(HASH);
	my $ok        = $is_hash && $class->get_meta_instance->is_inlinable;
	
	# Use inlined get method as a heuristic to detect weird shit.
	if ($ok)
	{
		my $inline_get = $self->_inline_instance_get('$X');
		$ok = !!0 if $inline_get ne sprintf('$X->{%s}', perlstring($self->name));
	}
	
	for my $m (qw/ accessor reader writer predicate clearer /)
	{
		my $has_method       = "has_$m";
		my $method_is_simple = "$m\_is_simple";
		my $methodname       = $self->$m;
		
		next unless $self->$has_method;
		
		# Generate it the old-fashioned way...
		my ($name, $metamethod) = $self->_process_accessors($m => $methodname, $inline);
		$class->add_method($name, $metamethod);
		
		# Now try to accelerate it!
		if ($ok and $self->$method_is_simple and exists $class_xsaccessor_opt{$m})
		{
			"Class::XSAccessor"->import(
				class                     => $classname,
				replace                   => 1,
				$class_xsaccessor_opt{$m} => +{ $methodname => $self->name },
			);
			# Naughty!
			no strict "refs";
			$metamethod->{"body"} = \&{"$classname\::$methodname"};
		}
	}
	
	$self->install_delegation if $self->has_handles;
	
	return;
};

1;

__END__

=pod

=for stopwords booleans

=encoding utf-8

=head1 NAME

MooseX::XSAccessor::Trait::Attribute - get the Class::XSAccessor effect for a single attribute

=head1 SYNOPSIS

   package MyClass;
   
   use Moose;
   
   has foo => (
      traits => ["MooseX::XSAccessor::Trait::Attribute"],
      ...,
   );
   
   say __PACKAGE__->meta->get_attribute("foo")->accessor_is_simple;

=head1 DESCRIPTION

Attributes with this trait have the following additional methods, which
each return booleans:

=over

=item C<< accessor_is_simple >>

=item C<< reader_is_simple >>

=item C<< writer_is_simple >>

=item C<< predicate_is_simple >>

=item C<< clearer_is_simple >>

=back

What is meant by simple? Simple enough for L<Class::XSAccessor> to take
over the accessor's duties.

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=MooseX-XSAccessor>.

=head1 SEE ALSO

L<MooseX::XSAccessor>.

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

