package MooseX::XSAccessor;

use 5.008;
use strict;
use warnings;

use Moose 2.0600 ();
use Class::XSAccessor 1.16 ();

BEGIN {
	$MooseX::XSAccessor::AUTHORITY = 'cpan:TOBYINK';
	$MooseX::XSAccessor::VERSION   = '0.001';
}

use Moose::Exporter;
Moose::Exporter->setup_import_methods;

sub init_meta
{
	shift;
	my %p = @_;
	Moose::Util::MetaRole::apply_metaroles(
		for             => $p{for_class},
		class_metaroles => {
			attribute => [qw( MooseX::XSAccessor::Meta::Attribute )],
		},
	);
}

BEGIN {
	package MooseX::XSAccessor::Meta::Attribute;
	
	use Moose::Role;
	
	sub accessor_is_simple
	{
		my $self = shift;
		return !!0 if $self->has_type_constraint;
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
		return !!0 if $self->has_type_constraint;
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
	
	my %class_xsaccessor_opt = (
		accessor   => "accessors",
		reader     => "getters",
		writer     => "setters",
		predicate  => "predicates",
	);
	
	override install_accessors => sub {
		my $self = shift;
		my ($inline) = @_;
		
		my $class     = $self->associated_class;
		my $classname = $class->name;
		
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
			if ($inline and $self->$method_is_simple and exists $class_xsaccessor_opt{$m})
			{
				"Class::XSAccessor"->import(
					class                     => $classname,
					replace                   => 1,
					$class_xsaccessor_opt{$m} => +{ $methodname => $self->name },
				);
				# Naughty!
				$metamethod->{"body"} = $classname->can($methodname);
			}
		}
		
		return;
	};
};

1;

__END__

=pod

=encoding utf-8

=head1 NAME

MooseX::XSAccessor - use Class::XSAccessor to speed up Moose accessors

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=MooseX-XSAccessor>.

=head1 SEE ALSO

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

