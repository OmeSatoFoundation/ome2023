#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([ome2023], 0.1, [d8221101@u-aizu.ac.jp])
AC_CONFIG_AUX_DIR([.])
AM_INIT_AUTOMAKE

# runstatedir not available for autoconf <= 2.69
if test "x$runstatedir" = "x" ; then
    runstatedir='${localstatedir}/run'
fi

# Checks for programs.
AC_PROG_MAKE_SET
AC_PROG_CC
AC_PROG_CPP
AC_PROG_CXX
AC_PROG_LN_S
PKG_PROG_PKG_CONFIG

## Check for git
AC_CHECK_PROG(have_git, git, git, [])
if test x"${have_git}" = x; then
    AC_MSG_ERROR([please install 'git'])
fi
## Check for git-lfs
AC_CHECK_PROG(have_git_lfs, git-lfs, yes)
if test x"${have_git_lfs}" != x"yes"; then
    AC_MSG_ERROR([please install 'git-lfs'. Do not forget to run `git lfs install`. https://github.com/git-lfs/git-lfs])
fi

AC_SUBST(have_git)

# Checks for libraries.

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([Makefile
                 contrib/Makefile
                 contrib/HTMLParse/Makefile
                 contrib/OpenHSP/Makefile
                 contrib/OpenHSPUtil/Makefile
                 contrib/FaBo/Makefile
                 contrib/JuliusMisc/Makefile
                 contrib/IR/Makefile
                 contrib/OpenJTalk/Makefile
                 contrib/WebServer/Makefile
                 contrib/Dictationkit/Makefile
                 contrib/Dictationkit/src/Makefile])
AX_SUBDIRS_CONFIGURE([contrib/Julius],
                     [[--with-mictype=alsa]],
                     [], [], [])
AC_OUTPUT
