#! perl

use Modern::Perl '2012';
use strict;
use warnings FATAL => 'all';
use autodie;
use version; our $VERSION = qv('v0.0.4');

use Carp;
use File::Next;
use File::Spec;
use File::stat;
use FindBin::Real qw(Bin Script);
use Getopt::Euclid;
use Readonly;
use Storable;

my $print_info = $ARGV{-v};
my $input      = $ARGV{-i};
my $force      = $ARGV{'-f'};
my $cache      = File::Spec->catfile( Bin(), '_cmtimes' );

Readonly my $SAYERR => 'Could not write to standard output.';

if ($print_info) {
    say "Looking for Perl sources in $input" or croak $SAYERR;
    say "perlcritic options: $ARGV{-C}"      or croak $SAYERR;
}

my $next_file = File::Next::files(
    {
        descend_filter => sub { $_ ne '.git' && $_ ne 'blib' },
        file_filter => sub { $_ =~ /[.](?:p[lm]|t)$/smx }
    },
    $input
);

my %mtimes = -e $cache ? %{ retrieve($cache) } : ();

while ( defined( my $file = $next_file->() ) ) {
    my $mtime = stat($file)->mtime;
    if ( ( !$force ) and $mtime ~~ $mtimes{$file} ) {
        next;
    }

    my $perlcritic = "perlcritic $ARGV{-C} $file";
    if ($print_info) {
        say $perlcritic or croak $SAYERR;
    }

    system $perlcritic;
    $mtimes{$file} = stat($file)->mtime;
    store \%mtimes, $cache;
}

exit 0;

__END__

=head1 NAME

criticizeall - Recursively find Perl sources and run perlcritic on them all

=head1 VERSION

This documentation refers to criticizeall version v0.0.4

=head1 USAGE

   criticizeall -in .\directory [options]

=head1 DESCRIPTION

'criticizeall' looks for perl sources in the input directory and its children 
and runs the perlcritic lint tool on each source file it finds.  The first time
criticizeall executes, it will store the modification times of the source files 
and on the next run, only modified files will be checked.  By default 
criticizeall searches the current directory if no directory is speicfied, and 
uses perlcritic's '-1' option to run with the maximum number of rules enabled.
You can use the '-f' option to force criticizeall to check all files, even those
which have not been modified.

=head1 REQUIRED ARGUMENTS

None.

=head1 OPTIONS

=over

=item -i[n] [=] <directory>

Specify input directory

=for Euclid
		directory.type: readable
		directory.default: '.'

=item -C [=] <opts>

=for Euclid
		opts.default: '-1'

criticizeall options

=item -f

Force criticism, even if the file appears unmodified.

=item -v

=item --verbose

Print all warnings

=item --version

=item --usage

=item --help

=item --man

Print the usual program information

=back

=head1 CONFIGURATION

None.

=head1 DIAGNOSTICS

None at this time.

=head1 EXIT STATUS

Zero on success.  No others defined at this time.

=head1 DEPENDENCIES

=over

    autodie
    Carp
    File::Next
    File::Spec
    File::stat
    FindBin::Real
    Getopt::Euclid
    Modern::Perl 2012
    Readonly
    Storable
    version

=back

=head1 INCOMPATIBILITIES

None known.

=head1 BUGS AND LIMITATIONS

None known.

=head1 AUTHOR

Jim Counts - @jamesrcounts

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2013 Jim Counts

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    L<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

