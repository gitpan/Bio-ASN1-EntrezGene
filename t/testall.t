#!/usr/bin/env perl -w
use strict;
use Test::More tests => 11;

my ($noindex, $noabseq, $nogene);

BEGIN {
  use_ok('Bio::ASN1::EntrezGene') || $nogene++;
  use_ok('Bio::Index::AbstractSeq') || $noabseq++;
  use_ok('Bio::ASN1::EntrezGene::Indexer') || $noindex++;
}
if(!$nogene)
{
  # first test parser
  my $parser = Bio::ASN1::EntrezGene->new(file => 't/input.asn');
  isa_ok($parser, 'Bio::ASN1::EntrezGene');
  my $value = $parser->next_seq;
  isa_ok($value, 'ARRAY');
  like($value->[0]{'track-info'}[0]{geneid}, qr/^\d+$/, 'correct geneid format');
  diag("parsing OK!\n");
  my $raw = $parser->rawdata;
  like($raw, qr/^Entrezgene ::=/, 'rawdata() call');
  # now test indexer
  if(!$noabseq)
  {
    if(!$noindex)
    {
      my $inx = Bio::ASN1::EntrezGene::Indexer->new(-filename => 't/test.idx',
                  -write_flag => 'WRITE');
      isa_ok($inx, 'Bio::ASN1::EntrezGene::Indexer');
      $inx->make_index('t/input.asn', 't/input1.asn');
      cmp_ok($inx->count_records, '==', 4, 'total number of indexed records');
      $value = $inx->fetch_hash(3);
      isa_ok($value, 'ARRAY');
      cmp_ok($value->[0]{'track-info'}[0]{geneid}, '==', 3, 'correct record retrieved');
      diag("indexer OK!\n");
    }
    else
    {
      diag("\nThere's some problem with the installation of Bio::ASN1::EntrezGene::Indexer!\nTry install again using:\n\tperl Makefile.PL\n\tmake\nQuitting now");
    }
  }
  else
  {
    diag("\nYou need to have Bio::Index::AbstractSeq (bioperl.org)\ninstalled for testing the indexer!\nQuitting now");
  }
}
else
{
  diag("\nThere's some problem with the installation of Bio::ASN1::EntrezGene!\nTry install again using:\n\tperl Makefile.PL\n\tmake\nQuitting now");
}

#
# # Various ways to say "ok"
# ok($this eq $that, $test_name);
#
# is  ($this, $that,    $test_name);
# isnt($this, $that,    $test_name);
#
# # Rather than print STDERR "# here's what went wrong\n"
# diag("here's what went wrong");
#
# like  ($this, qr/that/, $test_name);
# unlike($this, qr/that/, $test_name);
#
# cmp_ok($this, '==', $that, $test_name);
#
# is_deeply($complex_structure1, $complex_structure2, $test_name);
#
# SKIP: {
#     skip $why, $how_many unless $have_some_feature;
#
#     ok( foo(),       $test_name );
#     is( foo(42), 23, $test_name );
# };
#
# TODO: {
#     local $TODO = $why;
#
#     ok( foo(),       $test_name );
#     is( foo(42), 23, $test_name );
# };
#
# can_ok($module, @methods);
# isa_ok($object, $class);
#
# pass($test_name);
# fail($test_name);
#
# # Utility comparison functions.
# eq_array(\@this, \@that);
# eq_hash(\%this, \%that);
# eq_set(\@this, \@that);

