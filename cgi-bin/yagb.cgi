#!/usr/bin/perl

# yagb - Yet Another GuestBook
package yagb;

use v5.10;
use lib ( './lib', '../lib' );
use strict;
use warnings;

use YAGB::Handler;
use YAGB::CAPTCHA;

# for debug
#use Data::Dumper;

# for mod_perl compatible
&main;

sub main {
    my $yagb = YAGB::Handler->new() or die "Cant create YAGB handler object: ".($YAGB::ERROR||'');
    my $tmpl;
    my ( $error, $header_sent, $post_ok );
    given ( $yagb->q->param('act') ) {
        when ( 'post_do' ) {
            $tmpl = $yagb->post_do();
        }
        when ( 'post_form' ) {
            $tmpl = $yagb->post_form();
        }
        when ( 'captcha' ) {
            $yagb->captcha();
        }
        default {
            $tmpl = $yagb->index();
        }
    }
    unless ( $yagb->param('header_sent') ) {
        print $yagb->q->header;
        print $tmpl->output;
    }
}
