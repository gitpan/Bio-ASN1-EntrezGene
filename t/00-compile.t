use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::Compile 2.027

use Test::More  tests => 4 + ($ENV{AUTHOR_TESTING} ? 1 : 0);



my @module_files = (
    'Bio/ASN1/EntrezGene.pm',
    'Bio/ASN1/EntrezGene/Indexer.pm',
    'Bio/ASN1/Sequence.pm',
    'Bio/ASN1/Sequence/Indexer.pm'
);



# no fake home requested

use IPC::Open3;
use IO::Handle;

my @warnings;
for my $lib (@module_files)
{
    # see L<perlfaq8/How can I capture STDERR from an external command?>
    my $stdin = '';     # converted to a gensym by open3
    my $stderr = IO::Handle->new;
    binmode $stderr, ':crlf' if $^O eq 'MSWin32';

    my $pid = open3($stdin, '>&STDERR', $stderr, qq{$^X -Mblib -e"require q[$lib]"});
    waitpid($pid, 0);
    is($? >> 8, 0, "$lib loaded ok");

    if (my @_warnings = <$stderr>)
    {
        warn @_warnings;
        push @warnings, @_warnings;
    }
}



is(scalar(@warnings), 0, 'no warnings found') if $ENV{AUTHOR_TESTING};


