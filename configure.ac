#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([ome2023], 0.1, [d8221101@u-aizu.ac.jp])
AC_CONFIG_AUX_DIR([.])
AM_INIT_AUTOMAKE

# Checks for programs.
AC_PROG_MAKE_SET

# Checks for libraries.

# Checks for header files.

# Checks for typedefs, structures, and compiler characteristics.

# Checks for library functions.

AC_CONFIG_FILES([Makefile
                 contrib/Makefile
                 contrib/OpenHSP/Makefile])
AC_CONFIG_SUBDIRS([contrib/Dictationkit
                   contrib/OpenHSP])
AX_SUBDIRS_CONFIGURE(
                     [contrib/Julius], 
                     [[--build=x86_64-pc-linux-gnu], [--host=aarch64-linux-gnu], [--target=aarch64-linux-gnu], [--with-mictype=alsa]],
                     [], [], [])
AC_OUTPUT
