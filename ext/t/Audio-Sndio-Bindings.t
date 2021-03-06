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

use 5.010000;
use strict;
use warnings;

use Test::More tests => 2;
BEGIN { use_ok('Audio::Sndio::Bindings', qw(:all)) };

my $fail = 0;
for my $constname (qw(
	MIO_IN MIO_OUT MIO_PORTANY POLLHUP POLLIN POLLOUT SIO_DEVANY
	SIO_ERROR SIO_IGNORE SIO_LE_NATIVE SIO_MAXVOL SIO_NCHAN SIO_NCONF
	SIO_NENC SIO_NRATE SIO_PLAY SIO_REC SIO_SYNC)) {
	next if (eval "my \$a = $constname; 1");
	if ($@ =~ /^Your vendor has not defined Audio::Sndio::Bindings macro $constname/) {
		print "# pass: $@";
	} else {
		print "# fail: $@";
		$fail = 1;
	}
}

ok($fail == 0, 'Constants');
