#!/usr/bin/env perl -w
use strict;
use Test::More tests => 7;

my ($noindex, $noabseq, $nogene);

BEGIN {
  diag("\n\nTest indexer (Bio::ASN1::EntrezGene::Indexer) - indexing and retrieval:\n");
  use_ok('Bio::ASN1::EntrezGene') || $nogene++;
  use_ok('Bio::Index::AbstractSeq') || $noabseq++;
  use_ok('Bio::ASN1::EntrezGene::Indexer') || $noindex++;
}
if(!$nogene)
{
  # test indexer
  if(!$noabseq)
  {
    if(!$noindex)
    {
      my $inx = Bio::ASN1::EntrezGene::Indexer->new(-filename => 't/test.idx',
                  -write_flag => 'WRITE');
      isa_ok($inx, 'Bio::ASN1::EntrezGene::Indexer');
      $inx->make_index('t/input.asn', 't/input1.asn');
      cmp_ok($inx->count_records, '==', 4, 'total number of indexed records');
      my $value = $inx->fetch_hash(3);
      isa_ok($value, 'ARRAY');
      cmp_ok($value->[0]{'track-info'}[0]{geneid}, '==', 3, 'correct record retrieved');
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

