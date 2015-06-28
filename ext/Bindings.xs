/*
 * Copyright (c) 2015 Steven McDonald <steven@steven-mcdonald.id.au>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

#include <poll.h>
#include <sndio.h>

#include "const-c.inc"

struct callback {
	SV* code;
	SV* arg;
};

struct perlsio_hdl {
	struct sio_hdl* hdl;
	struct callback onmove;
	struct callback onvol;
	int npfd;
	struct pollfd* pfd;
};

struct perlmio_hdl {
	struct mio_hdl* hdl;
	int npfd;
	struct pollfd* pfd;
};

#define get_uv(key) do { \
		if ((sv = hv_fetchs(parh, #key, 0))) { \
			uv = SvUV(*sv); \
			if (uv > UINT_MAX) { \
				RETVAL = 0; \
				goto err; \
			} \
			par.key = uv; \
		} \
	} while (0)

#define put_uv(hash, strukt, key) do { \
		sv = newSVuv(strukt.key); \
		if (!(hv_stores(hash, #key, sv))) { \
			SvREFCNT_dec(sv); \
			RETVAL = 0; \
			goto err; \
		} \
	} while (0)

#define put_uvs(key, n) do { \
		av = newAV(); \
		for (i=0; i<n; i++) { \
			av_push(av, newSVuv(cap.key[i])); \
		} \
		if (!(hv_stores(caph, #key, newRV_noinc((SV*)av)))) { \
			RETVAL = 0; \
			goto err; \
		} \
		av = NULL; \
	} while (0)

#define alloc_pfds() do { \
		if (n > hdl->npfd) { \
			if (hdl->pfd) { \
				Safefree(hdl->pfd); \
				hdl->pfd  = NULL; \
				hdl->npfd = 0; \
			} \
			Newxz(hdl->pfd, n, struct pollfd); \
			if (hdl->pfd) \
				hdl->npfd = n; \
		} \
	} while (0)

static inline char *
sv_to_buf(SV* sv, size_t size) {
	if (!SvROK(sv))
		return NULL;

	sv = SvRV(sv);

	/*
	 * The discrepancy in allocation sizes here (size vs. size+1) is due
	 * to newSV automatically allocating an extra byte for the null
	 * terminator, whereas SvGROW does not.
	 */
	if (!SvOK(sv))
		SvSetSV(sv, newSV(size));
	return SvGROW(sv, size+1);
}

static inline void
run_callback(void *arg, SV* sv) {
	struct callback* cb = (struct callback*) arg;
	dSP;

	ENTER;
	SAVETMPS;

	PUSHMARK(SP);
	XPUSHs(sv_2mortal(newSVsv(cb->arg)));
	XPUSHs(sv_2mortal(sv));
	PUTBACK;

	call_sv(cb->code, G_VOID|G_DISCARD);

	FREETMPS;
	LEAVE;
}

static void
run_onmove(void *arg, int delta) {
	run_callback(arg, newSViv(delta));
}

static void
run_onvol(void *arg, unsigned int vol) {
	run_callback(arg, newSVuv(vol));
}

MODULE = Audio::Sndio::Bindings		PACKAGE = Audio::Sndio::Bindings		

INCLUDE: const-xs.inc

TYPEMAP: <<END
struct perlsio_hdl *	T_IV
struct perlmio_hdl *	T_IV
END

struct perlsio_hdl *
sio_open(name, mode, nbio_flag)
		const char * name
		unsigned int mode
		int nbio_flag
	CODE:
		RETVAL = NULL;
		Newxz(RETVAL, 1, struct perlsio_hdl);
		if (RETVAL) {
			RETVAL->hdl = sio_open(name, mode, nbio_flag);
			/* If we have no sio_hdl, no point returning success. */
			if (!RETVAL->hdl) {
				Safefree(RETVAL);
				RETVAL = NULL;
			}
		}
	OUTPUT:
		RETVAL

void
sio_close(hdl)
		struct perlsio_hdl * hdl
	CODE:
		sio_close(hdl->hdl);
		if (hdl->onmove.code)
			SvREFCNT_dec(hdl->onmove.code);
		if (hdl->onmove.arg)
			SvREFCNT_dec(hdl->onmove.arg);
		if (hdl->onvol.code)
			SvREFCNT_dec(hdl->onvol.code);
		if (hdl->onvol.arg)
			SvREFCNT_dec(hdl->onvol.arg);
		if (hdl->pfd)
			Safefree(hdl->pfd);
		Safefree(hdl);

int
sio_setpar(hdl, parh)
		struct perlsio_hdl * hdl
		HV * parh
	INIT:
		struct sio_par par;
		SV ** sv;
		UV uv;
	CODE:
		sio_initpar(&par);
		get_uv(bits);
		get_uv(bps);
		get_uv(sig);
		get_uv(le);
		get_uv(msb);
		get_uv(rchan);
		get_uv(pchan);
		get_uv(rate);
		get_uv(bufsz);
		get_uv(xrun);
		get_uv(round);
		get_uv(appbufsz);
		RETVAL = sio_setpar(hdl->hdl, &par);
		err:
	OUTPUT:
		RETVAL

int
sio_getpar(hdl, parh)
		struct perlsio_hdl * hdl
		HV * parh
	INIT:
		struct sio_par par;
		SV * sv;
	CODE:
		if (!(RETVAL = sio_getpar(hdl->hdl, &par)))
			goto err;
		put_uv(parh, par, bits);
		put_uv(parh, par, bps);
		put_uv(parh, par, sig);
		put_uv(parh, par, le);
		put_uv(parh, par, msb);
		put_uv(parh, par, rchan);
		put_uv(parh, par, pchan);
		put_uv(parh, par, rate);
		put_uv(parh, par, bufsz);
		put_uv(parh, par, xrun);
		put_uv(parh, par, round);
		put_uv(parh, par, appbufsz);
		err:
	OUTPUT:
		RETVAL

int
sio_getcap(hdl, caph)
		struct perlsio_hdl * hdl
		HV * caph
	INIT:
		struct sio_cap cap;
		SV * sv;
		AV * av;
		HV * hv;
		unsigned int i;
	CODE:
		if (!(RETVAL = sio_getcap(hdl->hdl, &cap)))
			goto err;

		/* extract enc */
		av = newAV();
		for (i=0; i<SIO_NENC; i++) {
			hv = newHV();
			put_uv(hv, cap.enc[i], bits);
			put_uv(hv, cap.enc[i], bps);
			put_uv(hv, cap.enc[i], sig);
			put_uv(hv, cap.enc[i], le);
			put_uv(hv, cap.enc[i], msb);
			av_push(av, newRV_noinc((SV*)hv));
			hv = NULL;
		}
		if (!(hv_stores(caph, "enc", newRV_noinc((SV*)av)))) {
			RETVAL = 0;
			goto err;
		}
		av = NULL;

		/* extract arrays of channels/rates */
		put_uvs(rchan, SIO_NCHAN);
		put_uvs(pchan, SIO_NCHAN);
		put_uvs(rate, SIO_NRATE);

		/* extract confs */
		av = newAV();
		for (i=0; i<cap.nconf; i++) {
			hv = newHV();
			put_uv(hv, cap.confs[i], enc);
			put_uv(hv, cap.confs[i], rchan);
			put_uv(hv, cap.confs[i], pchan);
			put_uv(hv, cap.confs[i], rate);
			av_push(av, newRV_noinc((SV*)hv));
			hv = NULL;
		}
		if (!(hv_stores(caph, "confs", newRV_noinc((SV*)av)))) {
			RETVAL = 0;
			goto err;
		}
		av = NULL;

		err:
		if (av)
			SvREFCNT_dec((SV*)av);
		if (hv)
			SvREFCNT_dec((SV*)hv);
	OUTPUT:
		RETVAL

int
sio_start(hdl)
		struct perlsio_hdl * hdl
	CODE:
		RETVAL = sio_start(hdl->hdl);
	OUTPUT:
		RETVAL

int
sio_stop(hdl)
		struct perlsio_hdl * hdl
	CODE:
		RETVAL = sio_stop(hdl->hdl);
	OUTPUT:
		RETVAL

size_t
sio_read(hdl, sv, nbytes)
		struct perlsio_hdl * hdl
		SV * sv
		size_t nbytes
	INIT:
		char * buf;
	CODE:
		RETVAL = 0;
		if ((buf = sv_to_buf(sv, (nbytes+1)))) {
			RETVAL = sio_read(hdl->hdl, (void*)buf, nbytes);
			buf[RETVAL] = '\0';
			SvLEN_set(sv, RETVAL);
		}
	OUTPUT:
		RETVAL

size_t
sio_write(hdl, sv, nbytes)
		struct perlsio_hdl * hdl
		SV * sv
		size_t nbytes
	INIT:
		char * buf;
	CODE:
		RETVAL = 0;
		if ((buf = sv_to_buf(sv, (nbytes+1))))
			RETVAL = sio_write(hdl->hdl, (void*)buf, nbytes);
	OUTPUT:
		RETVAL

void
sio_onmove(hdl, code, arg)
		struct perlsio_hdl * hdl
		SV * code
		SV * arg
	CODE:
		if (hdl->onmove.code) {
			SvSetSV(hdl->onmove.code, code);
			SvSetSV(hdl->onmove.arg, arg);
		} else {
			/* First time we've been called, so do the initial setup. */
			hdl->onmove.code = newSVsv(code);
			hdl->onmove.arg  = newSVsv(arg);
			sio_onmove(hdl->hdl, run_onmove, (void*)&hdl->onmove);
		}

int
sio_pollfd(hdl, events)
		struct perlsio_hdl * hdl
		int events
	INIT:
		int n;
	CODE:
		n = sio_nfds(hdl->hdl);
		alloc_pfds();
		if (hdl->npfd >= n)
			RETVAL = sio_pollfd(hdl->hdl, hdl->pfd, events);
		else
			RETVAL = 0;
	OUTPUT:
		RETVAL

int
sio_revents(hdl)
		struct perlsio_hdl * hdl
	CODE:
		if (hdl->pfd)
			RETVAL = sio_revents(hdl->hdl, hdl->pfd);
		else
			RETVAL = 0;
	OUTPUT:
		RETVAL

int
sio_eof(hdl)
		struct perlsio_hdl * hdl
	CODE:
		RETVAL = sio_eof(hdl->hdl);
	OUTPUT:
		RETVAL

int
sio_setvol(hdl, vol)
		struct perlsio_hdl * hdl
		unsigned int vol
	CODE:
		RETVAL = sio_setvol(hdl->hdl, vol);
	OUTPUT:
		RETVAL

int
sio_onvol(hdl, code, arg)
		struct perlsio_hdl * hdl
		SV * code
		SV * arg
	CODE:
		if (hdl->onvol.code) {
			SvSetSV(hdl->onvol.code, code);
			SvSetSV(hdl->onvol.arg, arg);
		} else {
			/* First time we've been called, so do the initial setup. */
			hdl->onvol.code = newSVsv(code);
			hdl->onvol.arg  = newSVsv(arg);
		}
		/* We need to call this every time because the return value is
		 * significant. */
		RETVAL = sio_onvol(hdl->hdl, run_onvol, (void*)&hdl->onvol);
	OUTPUT:
		RETVAL

struct perlmio_hdl *
mio_open(name, mode, nbio_flag)
		const char * name
		unsigned int mode
		int nbio_flag
	CODE:
		RETVAL = NULL;
		Newxz(RETVAL, 1, struct perlmio_hdl);
		if (RETVAL) {
			RETVAL->hdl = mio_open(name, mode, nbio_flag);
			/* If we have no mio_hdl, no point returning success. */
			if (!RETVAL->hdl) {
				Safefree(RETVAL);
				RETVAL = NULL;
			}
		}
	OUTPUT:
		RETVAL

void
mio_close(hdl)
		struct perlmio_hdl * hdl
	CODE:
		mio_close(hdl->hdl);
		if (hdl->pfd)
			Safefree(hdl->pfd);
		Safefree(hdl);

size_t
mio_read(hdl, sv, nbytes)
		struct perlmio_hdl * hdl
		SV * sv
		size_t nbytes
	INIT:
		char * buf;
	CODE:
		RETVAL = 0;
		if ((buf = sv_to_buf(sv, (nbytes+1)))) {
			RETVAL = mio_read(hdl->hdl, (void*)buf, nbytes);
			buf[RETVAL] = '\0';
			SvLEN_set(sv, RETVAL);
		}
	OUTPUT:
		RETVAL

size_t
mio_write(hdl, sv, nbytes)
		struct perlmio_hdl * hdl
		SV * sv
		size_t nbytes
	INIT:
		char * buf;
	CODE:
		RETVAL = 0;
		if ((buf = sv_to_buf(sv, (nbytes+1))))
			RETVAL = mio_write(hdl->hdl, (void*)buf, nbytes);
	OUTPUT:
		RETVAL

int
mio_pollfd(hdl, events)
		struct perlmio_hdl * hdl
		int events
	INIT:
		int n;
	CODE:
		n = mio_nfds(hdl->hdl);
		allow_pfds();
		if (hdl->npfd >= n)
			RETVAL = mio_pollfd(hdl->hdl, hdl->pfd, events);
		else
			RETVAL = 0;
	OUTPUT:
		RETVAL

int
mio_revents(hdl)
		struct perlmio_hdl * hdl
	CODE:
		if (hdl->pfd)
			RETVAL = mio_revents(hdl->hdl, hdl->pfd);
		else
			RETVAL = 0;
	OUTPUT:
		RETVAL

int
mio_eof(hdl)
		struct perlmio_hdl * hdl
	CODE:
		RETVAL = mio_eof(hdl->hdl);
	OUTPUT:
		RETVAL
