package YAGB::DB;

=pod

=head1 NAME

YAGB::DB - DB interface

=head1 SYNOPSIS

  my $db = YAGB::DB->new();

=head1 DESCRIPTION

Yet Another GuestBook DB interface

=head1 METHODS

=cut

use v5.10;
use parent 'DBI';
use strict;
use warnings;

our $VERSION = '0.01';
our @EXPORT_OK = qw( db_connect dbh );

use Carp;

=pod

=head2 connect

  my $dbh = YAGB::DB->connect($params);

The C<new> constructor lets you create a new B<YAGB::DB> object.
DB connect here.
Returns $dbh object or undef on error.

=cut

sub db_connect {
    my $self = shift;
    my $params = shift;
    return unless $params->{driver};
    $self->{_dbh} = DBI->connect('DBI:'.$params->{driver}.':dbname=' . ($params->{dir}||'') . $params->{name}
                                . ($params->{host}?';host='.$params->{host}:''),
                                $params->{user}, $params->{password}, { PrintError=>0, RaiseError=>1 })
        or die "Can't connect to database\nError: $DBI::errstr\n";
    # set connect state
    $self->{_db_connect} = 1;
    return $self->{_dbh};
}


=head2 dbh([$dbh])

Get/Set value of dbh

=cut

sub dbh {
    my ($self,$dbh) = @_;
    if ( $dbh ) { $self->{_dbh} = $dbh; $self->{_connect} = 1; }
    croak "Must call db_connect() before calling dbh()" unless $self->{_dbh};
    return $self->{_dbh};
}


=head2 DESTROY

db disconnect here

=cut

sub DESTROY {
    my $self = shift;
    $self->disconnect;
}

1;

=pod

=head1 AUTHOR

Copyright 2010 Sergiy Borodych <bor@univ.kiev.ua>.

=cut
