# Copyright (c) 2015 Steven McDonald <steven@steven-mcdonald.id.au>
#
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

package Audio::Sndio::Bindings;

use 5.010000;
use strict;
use warnings;

use AutoLoader;
use Carp qw(croak);

use base qw(Exporter);

our $VERSION = "0.01";

our %EXPORT_TAGS = (
	constants => [qw(
		MIO_IN MIO_OUT MIO_PORTANY POLLHUP POLLIN POLLOUT SIO_DEVANY
		SIO_ERROR SIO_IGNORE SIO_LE_NATIVE SIO_MAXVOL SIO_NCHAN SIO_NCONF
		SIO_NENC SIO_NRATE SIO_PLAY SIO_REC SIO_SYNC
	)],
	subs      => [qw(
		mio_open mio_close mio_read mio_write mio_pollfd mio_revents
		mio_eof sio_open sio_close sio_setpar sio_getpar sio_getcap
		sio_start sio_stop sio_read sio_write sio_onmove sio_pollfd
		sio_revents sio_eof sio_setvol sio_onvol
	)],
);
$EXPORT_TAGS{all} = [@{$EXPORT_TAGS{constants}}, @{$EXPORT_TAGS{subs}}];
our @EXPORT_OK = (@{$EXPORT_TAGS{all}});

sub AUTOLOAD {
	# This AUTOLOAD is used to "autoload" constants from the constant()
	# XS function.
	my $constname;
	our $AUTOLOAD;
	($constname = $AUTOLOAD) =~ s/.*:://;
	croak "&Audio::Sndio::Bindings::constant not defined" if $constname eq 'constant';
	my ($error, $val) = constant($constname);
	if ($error) { croak $error; }
	{
		no strict 'refs';
		*$AUTOLOAD = sub { $val };
	}
	goto &$AUTOLOAD;
}

require XSLoader;
XSLoader::load("Audio::Sndio::Bindings", $VERSION);

1;
__END__

=head1 NAME

Audio::Sndio::Bindings - Low-level Perl bindings for libsndio

=head1 SYNOPSIS

  use Audio::Sndio::Bindings qw(:all);
  my $sio = sio_open(SIO_DEVANY, SIO_PLAY, 0);

  my %params = (bits => 16, sig => 1, le => 1, rchan => 2,
    rate => 44100);
  sio_setpar($sio, \%params) or die "setpar failed";
  sio_getpar($sio, \%params) or die "getpar failed";
  $params{bits}  = 16    or die "Setting bits => 16 failed";
  $params{sig}   = 1     or die "Setting sig => 1 failed";
  $params{le}    = 1     or die "Setting le => 1 failed";
  $params{rchan} = 2     or die "Setting rchan => 2 failed";
  $params{rate}  = 44100 or die "Setting rate => 44100 failed";

  sio_start($sio) or die "sio_start failed";
  my $buf = generate_raw_audio();
  sio_write($sio, \$buf, length $buf);
  sio_stop($sio) or die "sio_stop failed";

  sio_close($sio);

=head1 DESCRIPTION

This module provides direct access to the C API of libsndio. Usually,
this is not what you want. See L<Audio::Sndio> for a more Perlish
interface.

This module does perform the bare minimum of abstractions that need to
be done in C. In particular:

=over 1

=item *
sio_par and sio_cap structs are exposed as Perl hashrefs. As a
consequence, sio_initpar is not provided by the Perl library, as all it
does is initialise a struct. sio_initpar is called under the hood by
sio_setpar.

=item *
pollfd allocation is done transparently. There is no sio_nfds or
mio_nfds, and the *_pollfd and *_revents subs lack the "pfd" argument.
Those are the only interfaces provided which have arguments differing
from the C API.

=item *
Callbacks are exposed as coderefs rather than C function pointers.

=item *
Audio buffers are exposed as raw Perl scalars, and treated as streams
of bytes under the hood.

=back

Anything that can be handled in Perl is not done here, including
checking for error codes; whatever value is returned from libsndio is
simply passed along as is.

If you're sure this is the library you want, every interface is the
same as those provided by the C API, modulo the exceptions above. Refer
to sio_open(3) and mio_open(3) for usage.

=head1 SEE ALSO

L<Audio::Sndio>, sndio(7), sio_open(3), mio_open(3)

=head1 AUTHOR

Steven McDonald, E<lt>steven@steven-mcdonald.id.auE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2015 Steven McDonald <steven@steven-mcdonald.id.au>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

=cut
