package YAGB::CAPTCHA;

=pod

=head1 NAME

YAGB::CAPTCHA - CAPTCHA interface

=head1 SYNOPSIS

  my $captcha = YAGB::CAPTCHA->new();

=head1 DESCRIPTION

Yet Another GuestBook CAPTCHA interface

=head1 METHODS

=cut

use v5.10;
use strict;
use warnings;

our $VERSION = '0.01';

=pod

=head2 new

  my $captcha = YAGB::CAPTCHA->new({ some_params => 'here' });

The C<new> constructor lets you create a new B<YAGB::CAPTCHA> object.
Create captcha image.
Params: nchars, width, height, strong.
Returns object or undef on error.

=cut

sub new {
    my $class = shift;
    my $params = shift;
    $params = {} unless $params;
    my $self = bless($params,$class);
    # some defaults
    $self->{nchars} ||= 4;
    $self->{width} ||= 80;
    $self->{height} ||= 30;
    $self->{strong} //= 5;
    return $self;
}


=head2 _create

Generate new image here.

=cut

sub _create {
    my $self = shift;
    require GD::SecurityImage;
    GD::SecurityImage->import; # or (use_magick => 1);
    my @chars = ('A'..'H','J'..'N','P'..'Z',2..9); # exclude O,0,1,I
    # random select style, exlude blank, box, ec styles
    my @styles = grep {s/^style_(?!blank|box|ec)//} keys %GD::SecurityImage::Styles::;
    my $style = $styles[int(rand(scalar(@styles)))];
    # create image
    my $image = GD::SecurityImage->new( width       => $self->{width},
                                        height      => $self->{height},
                                        #ptsize      => 12,
                                        lines       => 1 + int(rand(1*$self->{strong})),
                                        thickness   => 1 + int(rand(0.1*$self->{strong})),
                                        rndmax      => $self->{nchars},
                                        rnd_data    => \@chars,
                                        #scramble    => 1,
                                        #angle       => 1 + int(rand(5*$self->{strong})),
                                        send_ctobg  => 1,
                                        gd_font     => 'giant',
                                      ) or die "Can't create GD::SecurityImage image object: $!\n";
    $image->random();
    $image->create('normal',$style) or die "Can't create captcha image: $!\n";
    $image->particle(int(1+rand(10+10*$self->{strong}))); # 1..100
    ($self->{_img_data}, $self->{_mime_type}, $self->{_code}) = $image->out(force => 'png');
    #warn "$self->{_mime_type}, $style, $self->{strong}, $self->{_code}\n";
    return 1;
}

=head2 code

Return code on already generated image.

=cut

sub code {
    my $self = shift;
    $self->_create unless $self->{_code};
    return $self->{_code};
}

=head2 img_data

Return already generated img binary data.

=cut

sub img_data {
    my $self = shift;
    $self->_create unless $self->{_img_data};
    return $self->{_img_data};
}

=head2 mime_type

Return mime type of already generated image.

=cut

sub mime_type {
    my $self = shift;
    $self->_create unless $self->{_mime_type};
    return $self->{_mime_type};
}


1;

=pod

=head1 AUTHOR

Copyright 2010 Sergiy Borodych <bor@univ.kiev.ua>.

=cut
