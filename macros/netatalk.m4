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

dnl Check whether to disable tickle SIGALARM stuff, which eases debugging
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

dnl Check for LDAP support, for client-side ACL visibility
AC_DEFUN([AC_NETATALK_LDAP], [
AC_MSG_CHECKING(for LDAP (necessary for client-side ACL visibility))
AC_ARG_WITH(ldap,
    [AS_HELP_STRING([--with-ldap[[=PATH]]],
        [LDAP support (default=auto)])],
        netatalk_cv_ldap=$withval,
        netatalk_cv_ldap=auto
        )
AC_MSG_RESULT($netatalk_cv_ldap)

save_CFLAGS="$CFLAGS"
save_LDFLAGS="$LDFLAGS"
save_LIBS="$LIBS"
CFLAGS=""
LDFLAGS=""
LIBS=""
LDAP_CFLAGS=""
LDAP_LDFLAGS=""
LDAP_LIBS=""

if test x"$netatalk_cv_ldap" != x"no" ; then
   if test x"$netatalk_cv_ldap" != x"yes" -a x"$netatalk_cv_ldap" != x"auto"; then
       CFLAGS="-I$netatalk_cv_ldap/include"
       LDFLAGS="-L$netatalk_cv_ldap/lib"
   fi
       AC_CHECK_HEADER([ldap.h], netatalk_cv_ldap=yes,
        [ if test x"$netatalk_cv_ldap" = x"yes" ; then
            AC_MSG_ERROR([Missing LDAP headers])
        fi
        netatalk_cv_ldap=no
        ])
    AC_CHECK_LIB(ldap, ldap_init, netatalk_cv_ldap=yes,
        [ if test x"$netatalk_cv_ldap" = x"yes" ; then
            AC_MSG_ERROR([Missing LDAP library])
        fi
        netatalk_cv_ldap=no
        ])
fi

if test x"$netatalk_cv_ldap" = x"yes"; then
    LDAP_CFLAGS="$CFLAGS"
    LDAP_LDFLAGS="$LDFLAGS"
    LDAP_LIBS="-lldap"
    AC_DEFINE(HAVE_LDAP,1,[Whether LDAP is available])
fi

AC_SUBST(LDAP_CFLAGS)
AC_SUBST(LDAP_LDFLAGS)
AC_SUBST(LDAP_LIBS)
CFLAGS="$save_CFLAGS"
LDFLAGS="$save_LDFLAGS"
LIBS="$save_LIBS"
])

dnl Check for ACL support
AC_DEFUN([AC_NETATALK_ACL], [
ac_cv_have_acls=no
AC_MSG_CHECKING(whether to support ACLs)
AC_ARG_WITH(acls,
    [AS_HELP_STRING([--with-acls],
        [Include ACL support (default=auto)])],
    [ case "$withval" in
      yes|no)
          with_acl_support="$withval"
          ;;
      *)
          with_acl_support=auto
          ;;
      esac ],
    [with_acl_support=auto])
AC_MSG_RESULT($with_acl_support)

if test x"$with_acl_support" = x"no"; then
    AC_MSG_RESULT(Disabling ACL support)
fi

if test x"$with_acl_support" != x"no" -a x"$ac_cv_have_acls" != x"yes" ; then
    # Runtime checks for POSIX ACLs
    AC_CHECK_LIB(acl,acl_get_file,[ACL_LIBS="$ACL_LIBS -lacl"])
    case "$host_os" in
    *linux*)
        AC_CHECK_LIB(attr,getxattr,[ACL_LIBS="$ACL_LIBS -lattr"])
        ;;
    esac

    AC_CACHE_CHECK([for POSIX ACL support],netatalk_cv_HAVE_POSIX_ACLS,[
        acl_LIBS=$LIBS
        LIBS="$LIBS $ACL_LIBS"
        AC_LINK_IFELSE([AC_LANG_PROGRAM([[
            #include <sys/types.h>
            #include <sys/acl.h>
        ]], [[
            acl_t acl;
            int entry_id;
            acl_entry_t *entry_p;
            return acl_get_entry(acl, entry_id, entry_p);
        ]])],
            [netatalk_cv_HAVE_POSIX_ACLS=yes; ac_cv_have_acls=yes],
            [netatalk_cv_HAVE_POSIX_ACLS=no; ac_cv_have_acls=no]
        )
        LIBS=$acl_LIBS
    ])

    if test x"$netatalk_cv_HAVE_POSIX_ACLS" = x"yes"; then
        AC_MSG_NOTICE(Using POSIX ACLs)
        AC_DEFINE(HAVE_POSIX_ACLS,1,[Whether POSIX ACLs are available])

        AC_CACHE_CHECK([for acl_get_perm_np],netatalk_cv_HAVE_ACL_GET_PERM_NP,[
            acl_LIBS=$LIBS
            LIBS="$LIBS $ACL_LIBS"
            AC_LINK_IFELSE([AC_LANG_PROGRAM([[
                #include <sys/types.h>
                #include <sys/acl.h>
            ]], [[
                acl_permset_t permset_d;
                acl_perm_t perm;
                return acl_get_perm_np(permset_d, perm);
            ]])],[netatalk_cv_HAVE_ACL_GET_PERM_NP=yes],[netatalk_cv_HAVE_ACL_GET_PERM_NP=no])
            LIBS=$acl_LIBS
        ])
        if test x"$netatalk_cv_HAVE_ACL_GET_PERM_NP" = x"yes"; then
            AC_DEFINE(HAVE_ACL_GET_PERM_NP,1,[Whether acl_get_perm_np() is available])
        fi

        AC_CACHE_CHECK([for acl_from_mode], netatalk_cv_HAVE_ACL_FROM_MODE,[
            acl_LIBS=$LIBS
            LIBS="$LIBS $ACL_LIBS"
            AC_CHECK_FUNCS(acl_from_mode,
                [netatalk_cv_HAVE_ACL_FROM_MODE=yes],
                [netatalk_cv_HAVE_ACL_FROM_MODE=no]
            )
            LIBS=$acl_LIBS
        ])
        if test x"netatalk_cv_HAVE_ACL_FROM_MODE" = x"yes"; then
           AC_DEFINE(HAVE_ACL_FROM_MODE,1,[Whether acl_from_mode() is available])
        fi
    fi
fi

if test x"$ac_cv_have_acls" = x"no" ; then
    if test x"$with_acl_support" = x"yes" ; then
        AC_MSG_ERROR(ACL support requested but not found)
    else
        AC_MSG_NOTICE(ACL support is not avaliable)
    fi
else
    AC_CHECK_HEADERS([acl/libacl.h])
    AC_DEFINE(HAVE_ACLS,1,[Whether ACLs support is available])
fi
AC_SUBST(ACL_LIBS)
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


