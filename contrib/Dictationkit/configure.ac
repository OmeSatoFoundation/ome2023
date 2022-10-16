#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([dictationkit], [4.5], [d8221101@u-aizu.ac.jp])
AC_CONFIG_SRCDIR([src/am-gmm_template.jconf])
AC_CONFIG_AUX_DIR([.])
AM_INIT_AUTOMAKE

# Checks for programs.
## Check for git
AC_CHECK_PROG(have_git, git, git, [])
if test x"${have_git}" = x; then
    AC_MSG_ERROR([please install 'git'])
fi
AC_SUBST(have_git)

# Checks for libraries.

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([Makefile src/Makefile])
AC_OUTPUT
