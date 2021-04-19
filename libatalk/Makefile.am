# Makefile.am for libatalk/

# This is the version info for the libatalk binary API.  It has three
# numbers:
#
#   Current  -- the number of the binary API that we're implementing
#   Revision -- which iteration of the implementation of the binary
#               API are we supplying?
#   Age      -- How many previous binary API versions do we also
#               support?
#
# To increment a VERSION_INFO (current:revision:age):
#    If the ABI didn't change, but any library code changed:
#        current:revision+1:age
#    If the ABI changed, but it's backward-compatible:
#        current+1:0:age+1
#    If the ABI changed and it isn't backward-compatible:
#        current+1:0:0
#

VERSION_INFO = 19:0:0

SUBDIRS = acl adouble bstring cnid dsi iniparser talloc util unicode vfs

lib_LTLIBRARIES = libatalk.la

libatalk_la_SOURCES = dummy.c

libatalk_la_LIBADD  = \
	@MYSQL_LIBS@ \
	acl/libacl.la \
	adouble/libadouble.la	\
	bstring/libbstring.la \
	cnid/libcnid.la \
	dsi/libdsi.la		\
	iniparser/libiniparser.la \
	talloc/libtalloc.la       \
	unicode/libunicode.la \
	util/libutil.la		\
	vfs/libvfs.la

libatalk_la_DEPENDENCIES = \
	acl/libacl.la \
	adouble/libadouble.la	\
	bstring/libbstring.la \
	cnid/libcnid.la \
	dsi/libdsi.la		\
	talloc/libtalloc.la       \
	iniparser/libiniparser.la \
	unicode/libunicode.la \
	util/libutil.la		\
	vfs/libvfs.la

libatalk_la_LDFLAGS = -version-info $(VERSION_INFO)

