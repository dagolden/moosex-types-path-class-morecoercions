use 5.008001;
use strict;
use warnings;

package MooseX::Types::Path::Class::MoreCoercions;
# ABSTRACT: More powerful coercion than MooseX::Types::Path::Class
# VERSION

use Moose;
use MooseX::Types::Stringlike qw/Stringable/;
use MooseX::Types::Path::Class ();
use Path::Class ();
use MooseX::Types -declare => [qw( Dir File AbsDir AbsFile )];

subtype Dir, as MooseX::Types::Path::Class::Dir;
coerce( Dir,
  @{ MooseX::Types::Path::Class::Dir->coercion->type_coercion_map },
  from Stringable, via { Path::Class::Dir->new("$_") },
);

subtype File, as MooseX::Types::Path::Class::File;
coerce( File,
  @{ MooseX::Types::Path::Class::File->coercion->type_coercion_map },
  from Stringable, via { Path::Class::File->new("$_") },
);

subtype AbsDir,
  as Dir,
  where { $_->is_absolute };

coerce( AbsDir,
  ( map { my $c = $_; (ref $c eq "CODE") ? sub { $c->(@_)->absolute } : $c }
        @{ Dir->coercion->type_coercion_map }
  ),
  from Dir, via { $_->absolute },
);

subtype AbsFile,
  as File,
  where { $_->is_absolute };

coerce( AbsFile,
  ( map { my $c = $_; (ref $c eq "CODE") ? sub { $c->(@_)->absolute } : $c }
        @{ File->coercion->type_coercion_map }
  ),
  from File, via { $_->absolute },
);

1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

  ### specification of type constraint with coercion

  package Foo;

  use Moose;
  use MooseX::Types::Path::Class::MoreCoercions qw/File AbsDir/;

  has filename => (
    is => 'ro',
    isa => File,
    coerce => 1,
  );

  has directory => (
    is => 'ro',
    isa => AbsDir,
    coerce => 1,
  );

  ### usage in code

  my $tmp = File::Temp->new;

  Foo->new( filename => $tmp ); # coerced to Path::Class::File
  Foo->new( directory => '.' ); # coerced to dir('.')->absolute

=head1 DESCRIPTION

This module extends L<MooseX::Types::Path::Class> with more powerful coercions,
including:

=for :list
* coercing objects with overloaded stringification
* coercing to absolute paths

=head1 SUBTYPES

This module uses L<MooseX::Types> to define the following subtypes.

=head2 Dir

C<Dir> is a subtype of C<MooseX::Types::Path::Class::Dir>.  Objects with
overloaded stringification are coerced as strings if coercion is enabled.

=head2 AbsDir

C<AbsDir> is a subtype of C<Dir> (above).
Objects are also coerced to an absolute path.

=head2 File

C<File> is a subtype of C<MooseX::Types::Path::Class::File>.  Objects with
overloaded stringification are coerced as strings if coercion is enabled.

=head2 AbsFile

C<AbsFile> is a subtype of C<File> (above).
Objects are also coerced to an absolute path.

=head1 CAVEATS

=head2 Usage with File::Temp

Because an argument is stringified and then coerced into a Path::Class object,
no reference to the original File::Temp argument is held.  Be sure to hold an
external reference to it to avoid immediate cleanup of the object at the end
of the enclosing scope.

=head1 SEE ALSO

=for :list
* L<Moose::Manual::Types>
* L<MooseX::Types::Path::Class>

=cut

# vim: ts=2 sts=2 sw=2 et:
