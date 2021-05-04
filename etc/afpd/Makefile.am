# Makefile.am for etc/afpd/

pkgconfdir = @PKGCONFDIR@
BUILT_SOURCES =
EXTRA_DIST =
CLEANFILES =
DISTCLEANFILES =

sbin_PROGRAMS = afpd

afpd_SOURCES = \
	afp_config.c \
	afp_dsi.c \
	afp_options.c \
	afp_util.c \
	afprun.c \
	appl.c \
	auth.c \
	catsearch.c \
	desktop.c \
	dircache.c \
	directory.c \
	enumerate.c \
	extattrs.c \
	fce_api.c \
	fce_util.c \
	file.c \
	filedir.c \
	fork.c \
	hash.c \
	main.c \
	mangle.c \
	messages.c  \
	ofork.c \
	status.c \
	switch.c \
	uam.c \
	uid.c \
	unix.c \
	volume.c


afpd_LDADD =  \
	$(top_builddir)/libatalk/libatalk.la \
	@LIBGCRYPT_LIBS@ @ACL_LIBS@ @GSSAPI_LIBS@ @KRB5_LIBS@ @MYSQL_LIBS@

afpd_LDFLAGS = -export-dynamic

afpd_CFLAGS = \
	@GSSAPI_CFLAGS@ @KRB5_CFLAGS@\
	-DAPPLCNAME \
	-DSERVERTEXT=\"$(SERVERTEXT)/\" \
	-D_PATH_AFPDUAMPATH=\"$(UAMS_PATH)/\" \
	-D_PATH_CONFDIR=\"$(pkgconfdir)/\" \
	-D_PATH_STATEDIR='"$(localstatedir)/netatalk/"'

if HAVE_ACLS
afpd_SOURCES += acls.c
endif

noinst_HEADERS = auth.h afp_config.h desktop.h directory.h fce_api_internal.h file.h \
	 filedir.h fork.h icon.h mangle.h misc.h status.h switch.h \
	 uam_auth.h uid.h unix.h volume.h hash.h extattrs.h \
	 dircache.h
