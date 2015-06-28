#define PERL_constant_NOTFOUND	1
#define PERL_constant_NOTDEF	2
#define PERL_constant_ISIV	3
#define PERL_constant_ISNO	4
#define PERL_constant_ISNV	5
#define PERL_constant_ISPV	6
#define PERL_constant_ISPVN	7
#define PERL_constant_ISSV	8
#define PERL_constant_ISUNDEF	9
#define PERL_constant_ISUV	10
#define PERL_constant_ISYES	11

#ifndef NVTYPE
typedef double NV; /* 5.6 and later define NVTYPE, and typedef NV to it.  */
#endif
#ifndef aTHX_
#define aTHX_ /* 5.6 or later define this for threading support.  */
#endif
#ifndef pTHX_
#define pTHX_ /* 5.6 or later define this for threading support.  */
#endif

static int
constant_7 (pTHX_ const char *name, IV *iv_return) {
  /* When generated this function returned values for the list of names given
     here.  However, subsequent manual editing may have added or removed some.
     MIO_OUT POLLHUP POLLOUT SIO_REC */
  /* Offset 0 gives the best switch position.  */
  switch (*name++) {
  case 'M':
    if (memEQ(name, "IO_OUT", 6)) {
    /*                M            */
#ifdef MIO_OUT
      *iv_return = MIO_OUT;
      return PERL_constant_ISIV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'P':
    if (memEQ(name, "OLLHUP", 6)) {
    /*                P            */
#ifdef POLLHUP
      *iv_return = POLLHUP;
      return PERL_constant_ISIV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    if (memEQ(name, "OLLOUT", 6)) {
    /*                P            */
#ifdef POLLOUT
      *iv_return = POLLOUT;
      return PERL_constant_ISIV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'S':
    if (memEQ(name, "IO_REC", 6)) {
    /*                S            */
#ifdef SIO_REC
      *iv_return = SIO_REC;
      return PERL_constant_ISIV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  }
  return PERL_constant_NOTFOUND;
}

static int
constant_8 (pTHX_ const char *name, IV *iv_return) {
  /* When generated this function returned values for the list of names given
     here.  However, subsequent manual editing may have added or removed some.
     SIO_NENC SIO_PLAY SIO_SYNC */
  /* Offset 4 gives the best switch position.  */
  switch (name[4]) {
  case 'N':
    if (memEQ(name, "SIO_NENC", 8)) {
    /*                   ^         */
#ifdef SIO_NENC
      *iv_return = SIO_NENC;
      return PERL_constant_ISIV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'P':
    if (memEQ(name, "SIO_PLAY", 8)) {
    /*                   ^         */
#ifdef SIO_PLAY
      *iv_return = SIO_PLAY;
      return PERL_constant_ISIV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'S':
    if (memEQ(name, "SIO_SYNC", 8)) {
    /*                   ^         */
#ifdef SIO_SYNC
      *iv_return = SIO_SYNC;
      return PERL_constant_ISIV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  }
  return PERL_constant_NOTFOUND;
}

static int
constant_9 (pTHX_ const char *name, IV *iv_return) {
  /* When generated this function returned values for the list of names given
     here.  However, subsequent manual editing may have added or removed some.
     SIO_ERROR SIO_NCHAN SIO_NCONF SIO_NRATE */
  /* Offset 8 gives the best switch position.  */
  switch (name[8]) {
  case 'E':
    if (memEQ(name, "SIO_NRAT", 8)) {
    /*                       E     */
#ifdef SIO_NRATE
      *iv_return = SIO_NRATE;
      return PERL_constant_ISIV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'F':
    if (memEQ(name, "SIO_NCON", 8)) {
    /*                       F     */
#ifdef SIO_NCONF
      *iv_return = SIO_NCONF;
      return PERL_constant_ISIV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'N':
    if (memEQ(name, "SIO_NCHA", 8)) {
    /*                       N     */
#ifdef SIO_NCHAN
      *iv_return = SIO_NCHAN;
      return PERL_constant_ISIV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'R':
    if (memEQ(name, "SIO_ERRO", 8)) {
    /*                       R     */
#ifdef SIO_ERROR
      *iv_return = SIO_ERROR;
      return PERL_constant_ISIV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  }
  return PERL_constant_NOTFOUND;
}

static int
constant_10 (pTHX_ const char *name, IV *iv_return, const char **pv_return) {
  /* When generated this function returned values for the list of names given
     here.  However, subsequent manual editing may have added or removed some.
     SIO_DEVANY SIO_IGNORE SIO_MAXVOL */
  /* Offset 8 gives the best switch position.  */
  switch (name[8]) {
  case 'N':
    if (memEQ(name, "SIO_DEVANY", 10)) {
    /*                       ^        */
#ifdef SIO_DEVANY
      *pv_return = SIO_DEVANY;
      return PERL_constant_ISPV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'O':
    if (memEQ(name, "SIO_MAXVOL", 10)) {
    /*                       ^        */
#ifdef SIO_MAXVOL
      *iv_return = SIO_MAXVOL;
      return PERL_constant_ISIV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 'R':
    if (memEQ(name, "SIO_IGNORE", 10)) {
    /*                       ^        */
#ifdef SIO_IGNORE
      *iv_return = SIO_IGNORE;
      return PERL_constant_ISIV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  }
  return PERL_constant_NOTFOUND;
}

static int
constant (pTHX_ const char *name, STRLEN len, IV *iv_return, const char **pv_return) {
  /* Initially switch on the length of the name.  */
  /* When generated this function returned values for the list of names given
     in this section of perl code.  Rather than manually editing these functions
     to add or remove constants, which would result in this comment and section
     of code becoming inaccurate, we recommend that you edit this section of
     code, and use it to regenerate a new set of constant functions which you
     then use to replace the originals.

     Regenerate these constant functions by feeding this entire source file to
     perl -x

#!perl -w
use ExtUtils::Constant qw (constant_types C_constant XS_constant);

my $types = {map {($_, 1)} qw(IV PV)};
my @names = (qw(MIO_IN MIO_OUT POLLHUP POLLIN POLLOUT SIO_ERROR SIO_IGNORE
	       SIO_LE_NATIVE SIO_MAXVOL SIO_NCHAN SIO_NCONF SIO_NENC SIO_NRATE
	       SIO_PLAY SIO_REC SIO_SYNC),
            {name=>"MIO_PORTANY", type=>"PV"},
            {name=>"SIO_DEVANY", type=>"PV"});

print constant_types(), "\n"; # macro defs
foreach (C_constant ("Audio::Sndio::Bindings", 'constant', 'IV', $types, undef, 3, @names) ) {
    print $_, "\n"; # C constant subs
}
print "\n#### XS Section:\n";
print XS_constant ("Audio::Sndio::Bindings", $types);
__END__
   */

  switch (len) {
  case 6:
    /* Names all of length 6.  */
    /* MIO_IN POLLIN */
    /* Offset 0 gives the best switch position.  */
    switch (*name++) {
    case 'M':
      if (memEQ(name, "IO_IN", 5)) {
      /*                M           */
#ifdef MIO_IN
        *iv_return = MIO_IN;
        return PERL_constant_ISIV;
#else
        return PERL_constant_NOTDEF;
#endif
      }
      break;
    case 'P':
      if (memEQ(name, "OLLIN", 5)) {
      /*                P           */
#ifdef POLLIN
        *iv_return = POLLIN;
        return PERL_constant_ISIV;
#else
        return PERL_constant_NOTDEF;
#endif
      }
      break;
    }
    break;
  case 7:
    return constant_7 (aTHX_ name, iv_return);
    break;
  case 8:
    return constant_8 (aTHX_ name, iv_return);
    break;
  case 9:
    return constant_9 (aTHX_ name, iv_return);
    break;
  case 10:
    return constant_10 (aTHX_ name, iv_return, pv_return);
    break;
  case 11:
    if (memEQ(name, "MIO_PORTANY", 11)) {
#ifdef MIO_PORTANY
      *pv_return = MIO_PORTANY;
      return PERL_constant_ISPV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  case 13:
    if (memEQ(name, "SIO_LE_NATIVE", 13)) {
#ifdef SIO_LE_NATIVE
      *iv_return = SIO_LE_NATIVE;
      return PERL_constant_ISIV;
#else
      return PERL_constant_NOTDEF;
#endif
    }
    break;
  }
  return PERL_constant_NOTFOUND;
}

