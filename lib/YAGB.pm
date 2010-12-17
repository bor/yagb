package YAGB;

=pod

=head1 NAME

YAGB - Yet Another GuestBook

=head1 SYNOPSIS

  my $yagb = YAGB->new();

=head1 DESCRIPTION

Yet Another GuestBook

=head1 METHODS

=cut

use lib ( './lib', '../lib' );
use strict;
use warnings;

our $VERSION = '0.01';

use CGI;
use Config::Tiny;
use Cwd;
use HTML::Template;
use YAGB::DB qw( db_connect dbh );

our $ERROR;

=pod

=head2 new

  my $yagb = YAGB->new();

The C<new> constructor lets you create a new B<YAGB> object.
Returns a new B<YAGB> or undef on error.

=cut

sub new {
    my $class = shift;
    my %params = @_;
    my $self = bless {}, $class;
    # load conf
    $self->conf_load();
    # set debug level
    #$self->debug(delete $self->{debug});
    # set dbh or connect to DB
    if ( $params{dbh} and ref($params{dbh}) ) {
        $self->dbh($params{dbh});
    }
    else {
        $self->db_connect($self->conf('db'));
    }
    return $self->error('Cant connect to DB!') unless $self->dbh;
    return $self;
}

=head2 conf([$what])

Return value of $what from conf,
or hashref with all conf unless $what exists

=cut

sub conf {
    my ($self,$what) = @_;
    return $what ? ($self->{_conf}{$what}//$self->{_conf}{_}{$what}) : $self->{_conf};
}

=head2 conf_load([$conf_file])

Load conf here

=cut

sub conf_load {
    my ($self,$conf_file) = @_;
    unless ( $conf_file and -e $conf_file ) {
        # get conf file from ENV (apache conf)
        if ( $ENV{YAGB_CONF} ) {
            $conf_file = $ENV{YAGB_CONF};
        }
        # get conf file from mod_perl env (apache conf)
        # use ->r() from CGI
        elsif ( $ENV{MOD_PERL} and $self->q and $self->q->r ) {
            $conf_file = $self->q->r->dir_config->get('YAGB_CONF');
        }
    }
    die "Cant determine conf file!" unless $conf_file and -e $conf_file;
    # try load conf from conf_file
    $self->{_conf} = Config::Tiny->read($conf_file)
        or die "Can't read conf file $conf_file: ".Config::Tiny->errstr."\n";
    # try detect main dir if not set
    unless ( $self->conf('main_dir') ) {
        $self->{_conf}{main_dir} = cwd();
        $self->{_conf}{main_dir} =~ s/\/(cgi-)?bin\/?$//;
        unless ( $self->{_conf}{main_dir} and -d $self->{_conf}{main_dir} ) {
            $self->{_conf}{main_dir} = $ENV{DOCUMENT_ROOT};
            $self->{_conf}{main_dir} =~ s/\/htdocs\/?$//;
        }
    }
    die "Cant determine main dir!" unless $self->conf('main_dir') and -d $self->conf('main_dir');
    # check db dir
    if ( $self->{_conf}{db}{dir} ) {
        $self->{_conf}{db}{dir} = $self->conf('main_dir').'/'.$self->{_conf}{db}{dir}
            if $self->{_conf}{db}{dir} and $self->{_conf}{db}{dir} !~ /^\//;
        $self->{_conf}{db}{dir} .= '/' if $self->{_conf}{db}{dir} and $self->{_conf}{db}{dir} !~ /\/$/;
    }
    return 1;
}

=head2 error

Set error message, access by $self->{ERROR} or $YAGB::ERROR,
but always return undef

=cut

sub error {
    my ($self,$msg) = @_;
    $self->{ERROR} = $ERROR = $msg;
    return;
}

=head2 load_tmpl

Load template, set tmpl,
return HTML::Template object on success

=cut

sub load_tmpl {
    my ($self,$tmpl_file) = @_;
    my $tmpl = HTML::Template->new( filename => $tmpl_file, path => $self->conf('main_dir').'/templates' )
        or die "Cant load template $tmpl_file";
    return $tmpl;
}

=head2 param('name',['value'])

Get/Set param.

=cut

sub param {
    my ($self,$name,$value) = @_;
    $self->{_param}{$name} = $value if defined $value;
    return $self->{_param}{$name};
}

=head2 q()

CGI query object, "lazy" load

=cut

sub q {
    my $self = shift;
    $self->{_q} = CGI->new() unless $self->{_q};
    return $self->{_q};
}

1;

=pod

=head1 AUTHOR

Copyright 2010 Sergiy Borodych <bor@univ.kiev.ua>.

=cut
