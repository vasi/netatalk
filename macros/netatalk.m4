dnl Kitchen sink for configuration macros

dnl Check for docbook
AC_DEFUN([AX_CHECK_DOCBOOK], [
# It's just rude to go over the net to build
XSLTPROC_FLAGS=--nonet
DOCBOOK_ROOT=
for i in /usr/local/etc/xml/catalog ;
do
    if test -f $i; then
          XML_CATALOG="$i"
    fi
done
if test -n "$XML_CATALOG" ; then
    for i in $(BREW --prefix docbook-xsl 2>/dev/null)/docbook-xsl ;
    do
        if test -d "$i"; then
            DOCBOOK_ROOT=$i
        fi
    done
fi
AC_CHECK_PROG(XSLTPROC,xsltproc,xsltproc,)
XSLTPROC_WORKS=no
if test -n "$XSLTPROC"; then
    AC_MSG_CHECKING([whether xsltproc works])
    if test -n "$XML_CATALOG"; then
        DB_FILE="http://docbook.sourceforge.net/release/xsl/current/xhtml/docbook.xsl"
    else
        DB_FILE="$DOCBOOK_ROOT/html/docbook.xsl"
    fi
    
    $XSLTPROC $XSLTPROC_FLAGS $DB_FILE >/dev/null 2>&1 << END
<?xml version="1.0" encoding='ISO-8859-1'?>
<!DOCTYPE book PUBLIC "-//OASIS//DTD DocBook XML V4.1.2//EN" "http://www.oasis-open.org/docbook/xml/4.1.2/docbookx.dtd">
<book id="test">
</book>
END
    if test "$?" = 0; then
        XSLTPROC_WORKS=yes
    fi
    AC_MSG_RESULT($XSLTPROC_WORKS)
fi
AM_CONDITIONAL(have_xsltproc, test "$XSLTPROC_WORKS" = "yes")
AC_SUBST(XML_CATALOG)
AC_SUBST(XSLTPROC_FLAGS)
AC_SUBST(DOCBOOK_ROOT)
AC_SUBST(CAT_ENTRY_START)
AC_SUBST(CAT_ENTRY_END)
])

dnl Check for dbus-glib, for AFP stats
AC_DEFUN([AC_NETATALK_DBUS_GLIB], [
  atalk_cv_with_dbus=no

  AC_ARG_WITH(afpstats,
    AS_HELP_STRING(
      [--with-afpstats],
      [Enable AFP statistics via dbus (default: enabled if dbus found)]
    ),,[withval=auto]
  )

  if test x"$withval" != x"no" ; then
    PKG_CHECK_MODULES(DBUS, dbus-1 >= 1.1, have_dbus=yes, have_dbus=no)
    PKG_CHECK_MODULES(DBUS_GLIB, dbus-glib-1, have_dbus_glib=yes, have_dbus_glib=no)
    PKG_CHECK_MODULES(DBUS_GTHREAD, gthread-2.0, have_dbus_gthread=yes, have_dbus_gthread=no)
    if test x$have_dbus_glib = xyes -a x$have_dbus = xyes -a x$have_dbus_gthread = xyes ; then
        saved_CFLAGS=$CFLAGS
        saved_LIBS=$LIBS
        CFLAGS="$CFLAGS $DBUS_GLIB_CFLAGS"
        LIBS="$LIBS $DBUS_GLIB_LIBS"
        AC_CHECK_FUNC([dbus_g_bus_get_private], [atalk_cv_with_dbus=yes], [atalk_cv_with_dbus=no])
        CFLAGS="$saved_CFLAGS"
        LIBS="$saved_LIBS"
    fi
  fi

  if test x"$withval" = x"yes" -a x"$atalk_cv_with_dbus" = x"no"; then
    AC_MSG_ERROR([afpstats requested but dbus-glib not found])
  fi

  AC_ARG_WITH(
      dbus-sysconf-dir,
      [AS_HELP_STRING([--with-dbus-sysconf-dir=PATH],[Path to dbus system bus security configuration directory (default: ${sysconfdir}/dbus-1/system.d/)])],
      ac_cv_dbus_sysdir=$withval,
      ac_cv_dbus_sysdir='${sysconfdir}/dbus-1/system.d'
  )
  DBUS_SYS_DIR=""
  if test x$atalk_cv_with_dbus = xyes ; then
      AC_DEFINE(HAVE_DBUS_GLIB, 1, [Define if support for dbus-glib was found])
      DBUS_SYS_DIR="$ac_cv_dbus_sysdir"
  fi

  AC_SUBST(DBUS_SYS_DIR)
  AC_SUBST(DBUS_CFLAGS)
  AC_SUBST(DBUS_LIBS)
  AC_SUBST(DBUS_GLIB_CFLAGS)
  AC_SUBST(DBUS_GLIB_LIBS)
  AC_SUBST(DBUS_GTHREAD_CFLAGS)
  AC_SUBST(DBUS_GTHREAD_LIBS)
  AM_CONDITIONAL(HAVE_DBUS_GLIB, test x$atalk_cv_with_dbus = xyes)
])

dnl Check for libevent
AC_DEFUN([AC_NETATALK_LIBEVENT], [
    PKG_CHECK_MODULES([EVENT], [libevent], [],
        [AC_MSG_ERROR([pkg-config could not find libevent])]
    )
])

dnl netatalk lockfile path
AC_DEFUN([AC_NETATALK_LOCKFILE], [
    AC_MSG_CHECKING([netatalk lockfile path])
    AC_ARG_WITH(
        lockfile,
        [AS_HELP_STRING([--with-lockfile=PATH],[Path of netatalk lockfile])],
        ac_cv_netatalk_lock=$withval,
        ac_cv_netatalk_lock=""
    )
    if test -z "$ac_cv_netatalk_lock" ; then
        ac_cv_netatalk_lock=/var/spool/locks/netatalk
        if test x"$atalk_cv_fhs_compat" = x"yes" ; then
            ac_cv_netatalk_lock=/var/run/netatalk.pid
        fi
    fi
    AC_DEFINE_UNQUOTED(PATH_NETATALK_LOCK, ["$ac_cv_netatalk_lock"], [netatalk lockfile path])
    AC_SUBST(PATH_NETATALK_LOCK, ["$ac_cv_netatalk_lock"])
    AC_MSG_RESULT([$ac_cv_netatalk_lock])
])

dnl 64bit platform check
AC_DEFUN([AC_NETATALK_64BIT_LIBS], [
AC_MSG_CHECKING([whether to check for 64bit libraries])
# Test if the compiler is in 64bit mode
echo 'int i;' > conftest.$ac_ext
atalk_cv_cc_64bit_output=no
if AC_TRY_EVAL(ac_compile); then
    case `/usr/bin/file conftest.$ac_objext` in
    *"ELF 64"*)
      atalk_cv_cc_64bit_output=yes
      ;;
    esac
fi
rm -rf conftest*

case $host_cpu:$atalk_cv_cc_64bit_output in
x86_64:yes)
    case $target_os in
    *)
        AC_MSG_RESULT([yes])
        atalk_libname="lib64"
        ;;
    esac
    ;;
*:*)
    AC_MSG_RESULT([no])
    atalk_libname="lib"
    ;;
esac
])

dnl Check whether to enable debug code
AC_DEFUN([AC_NETATALK_DEBUG], [
AC_MSG_CHECKING([whether to enable verbose debug code])
AC_ARG_ENABLE(debug,
	[  --enable-debug          enable verbose debug code],[
	if test "$enableval" != "no"; then
		if test "$enableval" = "yes"; then
			AC_DEFINE(DEBUG, 1, [Define if verbose debugging information should be included])
		else
			AC_DEFINE_UNQUOTED(DEBUG, $enableval, [Define if verbose debugging information should be included])
		fi 
		AC_MSG_RESULT([yes])
	else
		AC_MSG_RESULT([no])
        AC_DEFINE(NDEBUG, 1, [Disable assertions])
	fi
	],[
		AC_MSG_RESULT([no])
        AC_DEFINE(NDEBUG, 1, [Disable assertions])
	]
)
])

dnl Check whethe to disable tickle SIGALARM stuff, which eases debugging
AC_DEFUN([AC_NETATALK_DEBUGGING], [
AC_MSG_CHECKING([whether to enable debugging with debuggers])
AC_ARG_ENABLE(debugging,
	[  --enable-debugging      disable SIGALRM timers and DSI tickles (eg for debugging with gdb/dbx/...)],[
	if test "$enableval" != "no"; then
		if test "$enableval" = "yes"; then
			AC_DEFINE(DEBUGGING, 1, [Define if you want to disable SIGALRM timers and DSI tickles])
		else
			AC_DEFINE_UNQUOTED(DEBUGGING, $enableval, [Define if you want to disable SIGALRM timers and DSI tickles])
		fi 
		AC_MSG_RESULT([yes])
	else
		AC_MSG_RESULT([no])
	fi
	],[
		AC_MSG_RESULT([no])
	]
)

])

dnl Check for building Kerberos V UAM module
AC_DEFUN([AC_NETATALK_KRB5_UAM], [
netatalk_cv_build_krb5_uam=no
AC_ARG_ENABLE(krbV-uam,
	[  --enable-krbV-uam       enable build of Kerberos V UAM module],
	[
		if test x"$enableval" = x"yes"; then
			NETATALK_GSSAPI_CHECK([
				netatalk_cv_build_krb5_uam=yes
			],[
				AC_MSG_ERROR([need GSSAPI to build Kerberos V UAM])
			])
		fi
	]
	
)

AC_MSG_CHECKING([whether Kerberos V UAM should be build])
if test x"$netatalk_cv_build_krb5_uam" = x"yes"; then
	AC_MSG_RESULT([yes])
else
	AC_MSG_RESULT([no])
fi
AM_CONDITIONAL(USE_GSSAPI, test x"$netatalk_cv_build_krb5_uam" = x"yes")
])

dnl Check if we can directly use Kerberos 5 API, used for reading keytabs
dnl and automatically construction DirectoryService names from that, instead
dnl of requiring special configuration in afp.conf
AC_DEFUN([AC_NETATALK_KERBEROS], [
AC_MSG_CHECKING([for Kerberos 5 (necessary for GetSrvrInfo:DirectoryNames support)])
AC_ARG_WITH([kerberos],
    [AS_HELP_STRING([--with-kerberos], [Kerberos 5 support (default=auto)])],
    [],
    [with_kerberos=auto])
AC_MSG_RESULT($with_kerberos)

if test x"$with_kerberos" != x"no"; then
   have_krb5_header="no"
   AC_CHECK_HEADERS([krb5/krb5.h krb5.h kerberosv5/krb5.h], [have_krb5_header="yes"; break])
   if test x"$have_krb5_header" = x"no" && test x"$with_kerberos" != x"auto"; then
      AC_MSG_FAILURE([--with-kerberos was given, but no headers found])
   fi

   AC_PATH_PROG([KRB5_CONFIG], [krb5-config])
   AC_MSG_CHECKING([for krb5-config])
   if test -x "$KRB5_CONFIG"; then
      AC_MSG_RESULT([$KRB5_CONFIG])
      KRB5_CFLAGS="`$KRB5_CONFIG --cflags krb5`"
      KRB5_LIBS="`$KRB5_CONFIG --libs krb5`"
      AC_SUBST(KRB5_CFLAGS)
      AC_SUBST(KRB5_LIBS)
      with_kerberos="yes"
   else
      AC_MSG_RESULT([not found])
      if test x"$with_kerberos" != x"auto"; then
         AC_MSG_FAILURE([--with-kerberos was given, but krb5-config could not be found])
      fi
   fi
fi

if test x"$with_kerberos" = x"yes"; then
   AC_DEFINE([HAVE_KERBEROS], [1], [Define if Kerberos 5 is available])
fi

dnl Check for krb5_free_unparsed_name and krb5_free_error_message
save_CFLAGS="$CFLAGS"
save_LIBS="$LIBS"
CFLAGS="$KRB5_CFLAGS"
LIBS="$KRB5_LIBS"
AC_CHECK_FUNCS([krb5_free_unparsed_name krb5_free_error_message krb5_free_keytab_entry_contents krb5_kt_free_entry])
CFLAGS="$save_CFLAGS"
LIBS="$save_LIBS"
])

dnl Check for overwrite the config files or not
AC_DEFUN([AC_NETATALK_OVERWRITE_CONFIG], [
AC_MSG_CHECKING([whether configuration files should be overwritten])
AC_ARG_ENABLE(overwrite,
	[  --enable-overwrite      overwrite configuration files during installation],
	[OVERWRITE_CONFIG="${enable_overwrite}"],
	[OVERWRITE_CONFIG="no"]
)
AC_MSG_RESULT([$OVERWRITE_CONFIG])
AC_SUBST(OVERWRITE_CONFIG)
])

dnl Check for Extended Attributes support
AC_DEFUN([AC_NETATALK_EXTENDED_ATTRIBUTES], [
neta_cv_eas="ad"
neta_cv_eas_sys_found=no
neta_cv_eas_sys_not_found=no

AC_CHECK_HEADERS(sys/attributes.h attr/xattr.h sys/xattr.h sys/extattr.h sys/uio.h sys/ea.h)

case "$this_os" in

  *)
	AC_SEARCH_LIBS(getxattr, [attr])

    if test "x$neta_cv_eas_sys_found" != "xyes" ; then
       AC_CHECK_FUNCS([getxattr lgetxattr fgetxattr listxattr llistxattr],
                      [neta_cv_eas_sys_found=yes],
                      [neta_cv_eas_sys_not_found=yes])
	   AC_CHECK_FUNCS([flistxattr removexattr lremovexattr fremovexattr],,
                      [neta_cv_eas_sys_not_found=yes])
	   AC_CHECK_FUNCS([setxattr lsetxattr fsetxattr],,
                      [neta_cv_eas_sys_not_found=yes])
    fi

    if test "x$neta_cv_eas_sys_found" != "xyes" ; then
	   AC_CHECK_FUNCS([getea fgetea lgetea listea flistea llistea],
                      [neta_cv_eas_sys_found=yes],
                      [neta_cv_eas_sys_not_found=yes])
	   AC_CHECK_FUNCS([removeea fremoveea lremoveea setea fsetea lsetea],,
                      [neta_cv_eas_sys_not_found=yes])
    fi

    if test "x$neta_cv_eas_sys_found" != "xyes" ; then
	   AC_CHECK_FUNCS([attr_get attr_list attr_set attr_remove],,
                      [neta_cv_eas_sys_not_found=yes])
       AC_CHECK_FUNCS([attr_getf attr_listf attr_setf attr_removef],,
                      [neta_cv_eas_sys_not_found=yes])
    fi
  ;;
esac

# Do xattr functions take additional options like on Darwin?
if test x"$ac_cv_func_getxattr" = x"yes" ; then
	AC_CACHE_CHECK([whether xattr interface takes additional options], smb_attr_cv_xattr_add_opt, [
		old_LIBS=$LIBS
		LIBS="$LIBS"
		AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
			#include <sys/types.h>
			#if HAVE_ATTR_XATTR_H
			#include <attr/xattr.h>
			#elif HAVE_SYS_XATTR_H
			#include <sys/xattr.h>
			#endif
		]], [[
			getxattr(0, 0, 0, 0, 0, 0);
		]])],[smb_attr_cv_xattr_add_opt=yes],[smb_attr_cv_xattr_add_opt=no;LIBS=$old_LIBS])
	])
	if test x"$smb_attr_cv_xattr_add_opt" = x"yes"; then
		AC_DEFINE(XATTR_ADD_OPT, 1, [xattr functions have additional options])
	fi
fi

if test "x$neta_cv_eas_sys_found" = "xyes" ; then
   if test "x$neta_cv_eas_sys_not_found" != "xyes" ; then
      neta_cv_eas="$neta_cv_eas | sys"
   fi
fi
AC_DEFINE_UNQUOTED(EA_MODULES,["$neta_cv_eas"],[Available Extended Attributes modules])
])

dnl Check for libsmbsharemodes from Samba for Samba/Netatalk access/deny/share modes interop
dnl Defines "neta_cv_have_smbshmd" to "yes" or "no"
dnl AC_SUBST's "SMB_SHAREMODES_CFLAGS" and "SMB_SHAREMODES_LDFLAGS"
dnl AM_CONDITIONAL's "USE_SMB_SHAREMODES"
AC_DEFUN([AC_NETATALK_SMB_SHAREMODES], [
    neta_cv_have_smbshmd=no
    AC_ARG_WITH(smbsharemodes-lib,
                [  --with-smbsharemodes-lib=PATH        PATH to libsmbsharemodes lib from Samba],
                [SMB_SHAREMODES_LDFLAGS="-L$withval -lsmbsharemodes"]
    )
    AC_ARG_WITH(smbsharemodes-include,
                [  --with-smbsharemodes-include=PATH    PATH to libsmbsharemodes header from Samba],
                [SMB_SHAREMODES_CFLAGS="-I$withval"]
    )
    AC_ARG_WITH(smbsharemodes,
                [AS_HELP_STRING([--with-smbsharemodes],[Samba interop (default is yes)])],
                [use_smbsharemodes=$withval],
                [use_smbsharemodes=yes]
    )

    if test x"$use_smbsharemodes" = x"yes" ; then
        AC_MSG_CHECKING([whether to enable Samba/Netatalk access/deny/share-modes interop])

        saved_CFLAGS="$CFLAGS"
        saved_LDFLAGS="$LDFLAGS"
        CFLAGS="$SMB_SHAREMODES_CFLAGS $CFLAGS"
        LDFLAGS="$SMB_SHAREMODES_LDFLAGS $LDFLAGS"

        AC_LINK_IFELSE(
            [#include <unistd.h>
             #include <stdio.h>
             #include <sys/time.h>
             #include <time.h>
             #include <stdint.h>
             /* From messages.h */
             struct server_id {
                 pid_t pid;
             };
             #include "smb_share_modes.h"
             int main(void) { (void)smb_share_mode_db_open(""); return 0;}],
            [neta_cv_have_smbshmd=yes]
        )

        AC_MSG_RESULT($neta_cv_have_smbshmd)
        AC_SUBST(SMB_SHAREMODES_CFLAGS, [$SMB_SHAREMODES_CFLAGS])
        AC_SUBST(SMB_SHAREMODES_LDFLAGS, [$SMB_SHAREMODES_LDFLAGS])
        CFLAGS="$saved_CFLAGS"
        LDFLAGS="$saved_LDFLAGS"
    fi

    AM_CONDITIONAL(USE_SMB_SHAREMODES, test x"$neta_cv_have_smbshmd" = x"yes")
])

dnl ------ Check for sendfile() --------
AC_DEFUN([AC_NETATALK_SENDFILE], [
netatalk_cv_search_sendfile=yes
AC_ARG_ENABLE(sendfile,
    [  --disable-sendfile       disable sendfile syscall],
    [if test x"$enableval" = x"no"; then
            netatalk_cv_search_sendfile=no
        fi]
)

if test x"$netatalk_cv_search_sendfile" = x"yes"; then
   case "$host_os" in
   *)
        ;;

    esac

    if test x"$netatalk_cv_HAVE_SENDFILE" = x"yes"; then
        AC_DEFINE(WITH_SENDFILE,1,[Whether sendfile() should be used])
    fi
fi
])

dnl ------ Check for recvfile() --------
AC_DEFUN([AC_NETATALK_RECVFILE], [
case "$host_os" in
*)
    ;;

esac

if test x"$atalk_cv_use_recvfile" = x"yes"; then
    AC_DEFINE(WITH_RECVFILE, 1, [Whether recvfile should be used])
fi
])

dnl --------------------- Check if realpath() takes NULL
AC_DEFUN([AC_NETATALK_REALPATH], [
AC_CACHE_CHECK([if the realpath function allows a NULL argument],
    neta_cv_REALPATH_TAKES_NULL, [
        AC_RUN_IFELSE([AC_LANG_SOURCE([[
            #include <stdio.h>
            #include <limits.h>
            #include <signal.h>

            void exit_on_core(int ignored) {
                 exit(1);
            }

            main() {
                char *newpath;
                signal(SIGSEGV, exit_on_core);
                newpath = realpath("/tmp", NULL);
                exit((newpath != NULL) ? 0 : 1);
            }]])],[neta_cv_REALPATH_TAKES_NULL=yes],[neta_cv_REALPATH_TAKES_NULL=no],[neta_cv_REALPATH_TAKES_NULL=cross
        ])
    ]
)

if test x"$neta_cv_REALPATH_TAKES_NULL" = x"yes"; then
    AC_DEFINE(REALPATH_TAKES_NULL,1,[Whether the realpath function allows NULL])
fi
])
