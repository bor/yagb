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

=pod

=head2 new

  my $dbh = YAGB::DB->new();

The C<new> constructor lets you create a new B<YAGB::DB> object.
DB connect here.
Returns $dbh object or undef on error.

=cut

sub new {
    my $class = shift;
    my $params = shift;
    return unless $params->{driver};
    my $self = DBI->connect('DBI:'.$params->{driver}.':dbname=' . ($params->{dir}||'') . $params->{name}
                                . ($params->{host}?';host='.$params->{host}:''),
                            $params->{user}, $params->{password}, { PrintError=>0, RaiseError=>1 })
        or die "Can't connect to database\nError: $DBI::errstr\n";
    # do not bless, because not worked
    #$self = bless($self,$class);
    return $self;
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
