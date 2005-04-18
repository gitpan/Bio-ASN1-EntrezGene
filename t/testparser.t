#!/usr/bin/env perl -w
use strict;
use Test::More tests => 5;

my $nogene;

BEGIN {
  diag("\n\nTest parser (Bio::ASN1::EntrezGene) - parsing and method call:\n");
  use_ok('Bio::ASN1::EntrezGene') || $nogene++;
}
if(!$nogene)
{
  my $parser = Bio::ASN1::EntrezGene->new(file => 't/input.asn');
  isa_ok($parser, 'Bio::ASN1::EntrezGene');
  my $value = $parser->next_seq;
  isa_ok($value, 'ARRAY');
  like($value->[0]{'track-info'}[0]{geneid}, qr/^\d+$/, 'correct geneid format');
  my $raw = $parser->rawdata;
  like($raw, qr/^Entrezgene ::=/, 'rawdata() call');
}
else
{
  diag("\nThere's some problem with the installation of Bio::ASN1::EntrezGene!\nTry install again using:\n\tperl Makefile.PL\n\tmake\nQuitting now");
}

