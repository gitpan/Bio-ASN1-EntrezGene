=head1 NAME

Bio::ASN1::EntrezGene::Indexer - Indexes NCBI Entrez Gene files.

=head1 SYNOPSIS

  use Bio::ASN1::EntrezGene::Indexer;

  # creating & using the index is just a few lines
  my $inx = Bio::ASN1::EntrezGene::Indexer->new(
    -filename => 'entrezgene.idx',
    -write_flag => 'WRITE'); # needed for make_index call, but if opening 
                             # existing index file, don't set write flag!
  $inx->make_index('Homo_sapiens', 'Mus_musculus', 'Rattus_norvegicus');
  my $seq = $inx->fetch(10); # Bio::Seq obj for Entrez Gene #10
  # alternatively, if one prefers just a data structure instead of objects
  $seq = $inx->fetch_hash(10); # a hash produced by Bio::ASN1::EntrezGene
                            # that contains all data in the Entrez Gene record

  # note that in case you wonder, you can get the files 'Homo_sapiens'
  # from NCBI Entrez Gene ftp download, DATA/ASN/Mammalia directory

=head1 PREREQUISITE

Bio::ASN1::EntrezGene, Bioperl version that contains Stefan Kirov's
entrezgene.pm and all dependencies therein.

=head1 INSTALLATION

Same as Bio::ASN1::EntrezGene

=head1 DESCRIPTION

Bio::ASN1::EntrezGene::Indexer is a Perl Indexer for NCBI Entrez Gene genome
databases. It processes an ASN.1-formatted Entrez Gene record and stores the
file position for each record in a way compliant with Bioperl standard (in
fact its a subclass of Bioperl's index objects).

Note that this module does not parse record, because it needs to run fast and
grab only the gene ids.  For parsing record, use Bio::ASN1::EntrezGene, or
better yet, use Bio::SeqIO, format 'entrezgene'.

It takes this module (version 1.07) 21 seconds to index the human genome
Entrez Gene file (Apr. 5/2005 download) on one 2.4 GHz Intel Xeon processor.

=head1 SEE ALSO

For details on various parsers I generated for Entrez Gene, example scripts that
uses/benchmarks the modules, please see L<http://sourceforge.net/projects/egparser/>.
Those other parsers etc. are included in V1.05 download.

=head1 AUTHOR

Dr. Mingyi Liu <mingyi.liu@gpc-biotech.com>

=head1 COPYRIGHT

The Bio::ASN1::EntrezGene module and its related modules and scripts
are copyright (c) 2005 Mingyi Liu, GPC Biotech AG and Altana Research
Institute. All rights reserved. I created these modules when working
on a collaboration project between these two companies. Therefore a
special thanks for the two companies to allow the release of the code
into public domain.

You may use and distribute them under the terms of the Perl itself or
GPL (L<http://www.gnu.org/copyleft/gpl.html>).

=head1 OPERATION SYSTEMS SUPPORTED

Any OS that Perl & Bioperl run on.

=head1 METHODS

=cut

package Bio::ASN1::EntrezGene::Indexer;

use strict;
use Carp qw(carp croak);
use vars qw ($VERSION @ISA);
use Bio::ASN1::EntrezGene;
use Bio::Index::AbstractSeq;

@ISA = qw(Bio::Index::AbstractSeq);
$VERSION = '1.07';

sub _version
{
  return $VERSION;
}

sub _type_stamp
{
  return '__EntrezGene_ASN1__';
}

sub _index_file 
{
  my($self, $file, $idx) = @_;
  my $position;
  open(IN, $file) || $self->throw("Can't open $file - $!");
  local $/ = "Entrezgene ::= {";
  while(<IN>)
  {
    chomp;
    $self->add_record($1, $idx, $position) if (/[,{}]\s+geneid\s*(\d+)\s+[,{}]/i);
    $position = tell(IN) - 16; # $/'s length
  }
  close(IN);
  return 1;
}

sub _file_format
{
  return 'entrezgene';
}

=head2 fetch

  Parameters: $geneid - id for the Entrez Gene record to be retrieved
  Example:    my $hash = $indexer->fetch(10); # get Entrez Gene #10
  Function:   fetch the data for the given Entrez Gene id.
  Returns:    A Bio::Seq object produced by Bio::SeqIO::entrezgene
  Notes:      One needs to have Bio::SeqIO::entrezgene installed before 
                calling this function!

=cut

=head2 fetch_hash

  Parameters: $geneid - id for the Entrez Gene record to be retrieved
  Example:    my $hash = $indexer->fetch_hash(10); # get Entrez Gene #10
  Function:   fetch a hash produced by Bio::ASN1::EntrezGene for given Entrez
                Gene id.
  Returns:    A data structure containing all data items from the Entrez
                Gene record.
  Notes:      Alternative to fetch()

=cut

sub fetch_hash
{
  my ($self, $geneid) = @_;
  if (my $gene = $self->db->{$geneid})
  {
    my ($fileno, $position) = $self->unpack_record($gene);
    my $parser = Bio::ASN1::EntrezGene->new('fh' => $self->_file_handle($fileno));
    seek($parser->fh, $position, 0);
    return $parser->next_seq;
  }
}

1;
