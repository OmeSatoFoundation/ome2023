#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([dictationkit], [4.5], [d8221101@u-aizu.ac.jp])
AC_CONFIG_SRCDIR([src/am-gmm.jconf.template])
AC_CONFIG_AUX_DIR([.])
AM_INIT_AUTOMAKE

# Checks for programs.
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

AC_CONFIG_FILES([Makefile src/Makefile])
AC_OUTPUT
