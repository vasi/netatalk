# Makefile.am for top level of netatalk package

SUBDIRS = include libatalk bin config etc contrib distrib doc man macros

EXTRA_DIST = CONTRIBUTORS COPYRIGHT COPYING NEWS VERSION

ACLOCAL_AMFLAGS = -I macros
AUTOMAKE_OPTIONS = foreign

#
# install init
#

install-exec-local:
	cp -p ./netatalkd @prefix@/bin

uninstall-local:
	rm -f @prefix@/bin/netatalkd
