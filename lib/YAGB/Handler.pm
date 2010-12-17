package YAGB::Handler;

=pod

=head1 NAME

YAGB::Handler

=head1 SYNOPSIS

  my $yagb = YAGB::Handler->new();

=head1 DESCRIPTION

Yet Another GuestBook Handler

=head1 METHODS

=cut

use lib ( './lib', '../lib' );
use parent YAGB;
use strict;
use warnings;

our $VERSION = '0.01';

use YAGB::CAPTCHA;

=pod

=head2 new

  my $captcha = YAGB::Handler->new();

The C<new> constructor lets you create a new B<YAGB::Handler> object.
Returns object or undef on error.

=cut

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(@_);
    $self = bless($self,$class);
    return $self;
}

=head2 captcha

=cut

sub captcha {
    my $self = shift;
    require CGI::Session;
    CGI::Session->name('YAGBSESID');
    my $session = CGI::Session->new(undef,$self->q) or die CGI::Session->errstr();
    my $captcha = YAGB::CAPTCHA->new($self->conf('captcha'));
    # store code in session
    $session->param('captcha'=>$captcha->code);
    $session->expire('+1h');
    # send session id in cookie
    print $self->q->header( -type => 'image/'.$captcha->mime_type,  -cookie => $session->cookie(),
                            -expires => 'now', '-Cache-Control' => 'no-cache', '-Pragma' => 'no-cache' );
    $self->param('header_sent',1);
    print $captcha->img_data;
}

=head2 index

=cut

sub index {
    my $self = shift;
    my $tmpl = $self->load_tmpl('index.html');
    $tmpl->param('post_ok',$self->param('post_ok'));
    # check input
    my ($order_by) = grep { $_ eq $self->q->param('order_by') } qw( name email post_time ) if $self->q->param('order_by');
    my ($order) = grep { $_ eq $self->q->param('order') } qw( desc asc ) if $self->q->param('order');
    # defaults
    $order_by ||= 'post_time';
    $order ||= 'desc';
    $tmpl->param( MESSAGES =>
                    $self->dbh->selectall_arrayref("SELECT name, email, homepage, message AS msg, post_time
                                                    FROM yagb_messages ORDER BY $order_by $order",
                                                { Slice => {} } )
    );
    return $tmpl;
}


=head2 post_do

=cut

sub post_do {
    my $self = shift;
    # check captcha
    if ( $self->conf('captcha_enable') ) {
        require CGI::Session;
        CGI::Session->name('YAGBSESID');
        my $session = CGI::Session->load($self->q) or die CGI::Session->errstr();
        if ( $session->is_empty or !$session->param('captcha') ) {
            $self->param('error','Session expired. Please try again.');
            return $self->post_form();
        }
        unless ( $session->param('captcha') eq $self->q->param('captcha') ) {
            $self->param('error','Bad captcha');
            return $self->post_form();
        }
    }
    $self->param('post_ok',1);
    # check input
    if ( !$self->q->param('name') or $self->q->param('name') !~ /^[\w\s]+$/ ) {
        $self->param('error_name',1);
        $self->param('post_ok',0);
    }
    if ( !$self->q->param('email') or $self->q->param('email') !~ /^[\w.]+@[\w\-]+\.[\w\-.]+$/ ) {
        $self->param('error_email',1);
        $self->param('post_ok',0);
    }
    if ( $self->q->param('url') and $self->q->param('url') !~ /^http:\/\/[\w\-.\/]+$/ ) {
        $self->param('error_url',1);
        $self->param('post_ok',0);
    }
    if ( !$self->q->param('msg') or $self->q->param('msg') =~ /<\w+[^>]*>/ ) {
        $self->param('error_msg',1);
        $self->param('post_ok',0);
    }
    return $self->post_form() unless $self->param('post_ok');
    # insert meassage into DB
    $self->dbh->do('INSERT INTO yagb_messages (name,email,homepage,message,post_time,ip,useragent) VALUES (?,?,?,?,?,?,?)',
            undef, $self->q->param('name'), $self->q->param('email'), $self->q->param('url'), $self->q->param('msg'),
            time(), $self->q->remote_addr, $self->q->user_agent );
    return $self->index();
}

=head2 post_form

=cut

sub post_form {
    my $self = shift;
    my $tmpl = $self->load_tmpl('post_form.html');
    # fill form fields & errors check
    foreach my $field ( qw( name email url msg ) ) {
        $tmpl->param($field,$self->q->param($field)) if $self->q->param($field);
        $tmpl->param('error_'.$field,1) if $self->param('error_'.$field);
    }
    $tmpl->param('captcha_enable',1) if $self->conf('captcha_enable');
    $tmpl->param('error',$self->param('error')) if $self->param('error');
    return $tmpl;
}

1;

=pod

=head1 AUTHOR

Copyright 2010 Sergiy Borodych <bor@univ.kiev.ua>.

=cut
