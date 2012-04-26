#!/bin/sh

PKG_NAME="busybox"
PKG_VER="1.20.0"
PKG_REV="1"
PKG_DESC="A tiny implementation of many Unix utilities"
PKG_CAT="BuildingBlock"
PKG_DEPS=""

# the required bug-fix patches
PATCHES="getty lineedit sed"

download() {
	# download the sources tarball
	if [ ! -f $PKG_NAME-$PKG_VER.tar.bz2 ]
	then
		download_file http://busybox.net/downloads/$PKG_NAME-$PKG_VER.tar.bz2
		[ $? -ne 0 ] && return 1
	fi

	# download the patches
	for patch in $PATCHES
	do
		[ -f $PKG_NAME-$PKG_VER-$patch.patch ] && continue
		download_file http://busybox.net/downloads/fixes-$PKG_VER/$PKG_NAME-$PKG_VER-$patch.patch
		[ $? -ne 0 ] && return 1
	done

	return 0
}

build() {
	# extract the sources tarball
	tar -xjvf $PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# apply the patches
	for patch in $PATCHES
	do
		patch -p1 < ../$PKG_NAME-$PKG_VER-$patch.patch
		[ $? -ne 0 ] && return 1
	done

	# remove the additional CFLAGS
	sed -i s/'-O2'//g Makefile
	[ $? -ne 0 ] && return 1
	case $PKG_ARCH in
		i?86)
			sed -i s/'-march=i386 '// arch/i386/Makefile
			[ $? -ne 0 ] && return 1
			;;
	esac

	# add the configuration
	cat << CONFIG_END > .config
#
# Automatically generated make config: don't edit
# Busybox version: 1.20.0
# Thu Apr 26 16:06:21 2012
#
CONFIG_HAVE_DOT_CONFIG=y

#
# Busybox Settings
#

#
# General Configuration
#
CONFIG_DESKTOP=y
CONFIG_EXTRA_COMPAT=y
CONFIG_INCLUDE_SUSv2=y
# CONFIG_USE_PORTABLE_CODE is not set
CONFIG_PLATFORM_LINUX=y
CONFIG_FEATURE_BUFFERS_USE_MALLOC=y
# CONFIG_FEATURE_BUFFERS_GO_ON_STACK is not set
# CONFIG_FEATURE_BUFFERS_GO_IN_BSS is not set
CONFIG_SHOW_USAGE=y
CONFIG_FEATURE_VERBOSE_USAGE=y
# CONFIG_FEATURE_COMPRESS_USAGE is not set
# CONFIG_FEATURE_INSTALLER is not set
# CONFIG_INSTALL_NO_USR is not set
CONFIG_LOCALE_SUPPORT=y
# CONFIG_UNICODE_SUPPORT is not set
# CONFIG_UNICODE_USING_LOCALE is not set
# CONFIG_FEATURE_CHECK_UNICODE_IN_ENV is not set
CONFIG_SUBST_WCHAR=0
CONFIG_LAST_SUPPORTED_WCHAR=0
# CONFIG_UNICODE_COMBINING_WCHARS is not set
# CONFIG_UNICODE_WIDE_WCHARS is not set
# CONFIG_UNICODE_BIDI_SUPPORT is not set
# CONFIG_UNICODE_NEUTRAL_TABLE is not set
# CONFIG_UNICODE_PRESERVE_BROKEN is not set
CONFIG_LONG_OPTS=y
CONFIG_FEATURE_DEVPTS=y
# CONFIG_FEATURE_CLEAN_UP is not set
# CONFIG_FEATURE_UTMP is not set
# CONFIG_FEATURE_WTMP is not set
# CONFIG_FEATURE_PIDFILE is not set
CONFIG_FEATURE_SUID=y
CONFIG_FEATURE_SUID_CONFIG=y
CONFIG_FEATURE_SUID_CONFIG_QUIET=y
# CONFIG_SELINUX is not set
# CONFIG_FEATURE_PREFER_APPLETS is not set
CONFIG_BUSYBOX_EXEC_PATH="/proc/self/exe"
CONFIG_FEATURE_SYSLOG=y
CONFIG_FEATURE_HAVE_RPC=y

#
# Build Options
#
# CONFIG_STATIC is not set
# CONFIG_PIE is not set
# CONFIG_NOMMU is not set
# CONFIG_BUILD_LIBBUSYBOX is not set
# CONFIG_FEATURE_INDIVIDUAL is not set
# CONFIG_FEATURE_SHARED_BUSYBOX is not set
CONFIG_LFS=y
CONFIG_CROSS_COMPILER_PREFIX=""
CONFIG_SYSROOT=""
CONFIG_EXTRA_CFLAGS="$CFLAGS"
CONFIG_EXTRA_LDFLAGS="$LDFLAGS"
CONFIG_EXTRA_LDLIBS=""

#
# Debugging Options
#
# CONFIG_DEBUG is not set
# CONFIG_DEBUG_PESSIMIZE is not set
# CONFIG_WERROR is not set
CONFIG_NO_DEBUG_LIB=y
# CONFIG_DMALLOC is not set
# CONFIG_EFENCE is not set

#
# Installation Options ("make install" behavior)
#
CONFIG_INSTALL_APPLET_SYMLINKS=y
# CONFIG_INSTALL_APPLET_HARDLINKS is not set
# CONFIG_INSTALL_APPLET_SCRIPT_WRAPPERS is not set
# CONFIG_INSTALL_APPLET_DONT is not set
# CONFIG_INSTALL_SH_APPLET_SYMLINK is not set
# CONFIG_INSTALL_SH_APPLET_HARDLINK is not set
# CONFIG_INSTALL_SH_APPLET_SCRIPT_WRAPPER is not set
CONFIG_PREFIX="$INSTALL_DIR"

#
# Busybox Library Tuning
#
# CONFIG_FEATURE_SYSTEMD is not set
CONFIG_FEATURE_RTMINMAX=y
CONFIG_PASSWORD_MINLEN=6
CONFIG_MD5_SMALL=0
CONFIG_FEATURE_FAST_TOP=y
# CONFIG_FEATURE_ETC_NETWORKS is not set
CONFIG_FEATURE_USE_TERMIOS=y
CONFIG_FEATURE_EDITING=y
CONFIG_FEATURE_EDITING_MAX_LEN=1024
# CONFIG_FEATURE_EDITING_VI is not set
CONFIG_FEATURE_EDITING_HISTORY=15
# CONFIG_FEATURE_EDITING_SAVEHISTORY is not set
# CONFIG_FEATURE_EDITING_SAVE_ON_EXIT is not set
# CONFIG_FEATURE_REVERSE_SEARCH is not set
CONFIG_FEATURE_TAB_COMPLETION=y
# CONFIG_FEATURE_USERNAME_COMPLETION is not set
CONFIG_FEATURE_EDITING_FANCY_PROMPT=y
# CONFIG_FEATURE_EDITING_ASK_TERMINAL is not set
# CONFIG_FEATURE_NON_POSIX_CP is not set
CONFIG_FEATURE_VERBOSE_CP_MESSAGE=y
CONFIG_FEATURE_COPYBUF_KB=4
# CONFIG_FEATURE_SKIP_ROOTFS is not set
CONFIG_MONOTONIC_SYSCALL=y
CONFIG_IOCTL_HEX2STR_ERROR=y
CONFIG_FEATURE_HWIB=y

#
# Applets
#

#
# Archival Utilities
#
CONFIG_FEATURE_SEAMLESS_XZ=y
CONFIG_FEATURE_SEAMLESS_LZMA=y
CONFIG_FEATURE_SEAMLESS_BZ2=y
CONFIG_FEATURE_SEAMLESS_GZ=y
CONFIG_FEATURE_SEAMLESS_Z=y
# CONFIG_AR is not set
# CONFIG_FEATURE_AR_LONG_FILENAMES is not set
# CONFIG_FEATURE_AR_CREATE is not set
CONFIG_BUNZIP2=y
CONFIG_BZIP2=y
CONFIG_CPIO=y
CONFIG_FEATURE_CPIO_O=y
CONFIG_FEATURE_CPIO_P=y
CONFIG_DPKG=y
CONFIG_DPKG_DEB=y
CONFIG_FEATURE_DPKG_DEB_EXTRACT_ONLY=y
CONFIG_GUNZIP=y
CONFIG_GZIP=y
CONFIG_FEATURE_GZIP_LONG_OPTIONS=y
CONFIG_GZIP_FAST=2
CONFIG_LZOP=y
# CONFIG_LZOP_COMPR_HIGH is not set
CONFIG_RPM2CPIO=y
CONFIG_RPM=y
CONFIG_TAR=y
CONFIG_FEATURE_TAR_CREATE=y
CONFIG_FEATURE_TAR_AUTODETECT=y
CONFIG_FEATURE_TAR_FROM=y
CONFIG_FEATURE_TAR_OLDGNU_COMPATIBILITY=y
# CONFIG_FEATURE_TAR_OLDSUN_COMPATIBILITY is not set
CONFIG_FEATURE_TAR_GNU_EXTENSIONS=y
CONFIG_FEATURE_TAR_LONG_OPTIONS=y
CONFIG_FEATURE_TAR_TO_COMMAND=y
CONFIG_FEATURE_TAR_UNAME_GNAME=y
CONFIG_FEATURE_TAR_NOPRESERVE_TIME=y
# CONFIG_FEATURE_TAR_SELINUX is not set
CONFIG_UNCOMPRESS=y
CONFIG_UNLZMA=y
CONFIG_FEATURE_LZMA_FAST=y
CONFIG_LZMA=y
CONFIG_UNXZ=y
CONFIG_XZ=y
CONFIG_UNZIP=y

#
# Coreutils
#
CONFIG_BASENAME=y
CONFIG_CAT=y
CONFIG_DATE=y
CONFIG_FEATURE_DATE_ISOFMT=y
CONFIG_FEATURE_DATE_NANO=y
CONFIG_FEATURE_DATE_COMPAT=y
CONFIG_HOSTID=y
CONFIG_ID=y
CONFIG_GROUPS=y
CONFIG_TEST=y
CONFIG_FEATURE_TEST_64=y
CONFIG_TOUCH=y
CONFIG_FEATURE_TOUCH_SUSV3=y
CONFIG_TR=y
CONFIG_FEATURE_TR_CLASSES=y
CONFIG_FEATURE_TR_EQUIV=y
CONFIG_BASE64=y
# CONFIG_WHO is not set
# CONFIG_USERS is not set
CONFIG_CAL=y
# CONFIG_CATV is not set
CONFIG_CHGRP=y
CONFIG_CHMOD=y
CONFIG_CHOWN=y
CONFIG_FEATURE_CHOWN_LONG_OPTIONS=y
CONFIG_CHROOT=y
CONFIG_CKSUM=y
# CONFIG_COMM is not set
CONFIG_CP=y
CONFIG_FEATURE_CP_LONG_OPTIONS=y
CONFIG_CUT=y
CONFIG_DD=y
CONFIG_FEATURE_DD_SIGNAL_HANDLING=y
CONFIG_FEATURE_DD_THIRD_STATUS_LINE=y
CONFIG_FEATURE_DD_IBS_OBS=y
CONFIG_DF=y
CONFIG_FEATURE_DF_FANCY=y
CONFIG_DIRNAME=y
CONFIG_DOS2UNIX=y
CONFIG_UNIX2DOS=y
CONFIG_DU=y
CONFIG_FEATURE_DU_DEFAULT_BLOCKSIZE_1K=y
CONFIG_ECHO=y
CONFIG_FEATURE_FANCY_ECHO=y
CONFIG_ENV=y
CONFIG_FEATURE_ENV_LONG_OPTIONS=y
CONFIG_EXPAND=y
CONFIG_FEATURE_EXPAND_LONG_OPTIONS=y
CONFIG_EXPR=y
CONFIG_EXPR_MATH_SUPPORT_64=y
CONFIG_FALSE=y
CONFIG_FOLD=y
CONFIG_FSYNC=y
CONFIG_HEAD=y
CONFIG_FEATURE_FANCY_HEAD=y
# CONFIG_INSTALL is not set
# CONFIG_FEATURE_INSTALL_LONG_OPTIONS is not set
CONFIG_LN=y
CONFIG_LOGNAME=y
CONFIG_LS=y
CONFIG_FEATURE_LS_FILETYPES=y
CONFIG_FEATURE_LS_FOLLOWLINKS=y
CONFIG_FEATURE_LS_RECURSIVE=y
CONFIG_FEATURE_LS_SORTFILES=y
CONFIG_FEATURE_LS_TIMESTAMPS=y
CONFIG_FEATURE_LS_USERNAME=y
CONFIG_FEATURE_LS_COLOR=y
# CONFIG_FEATURE_LS_COLOR_IS_DEFAULT is not set
CONFIG_MD5SUM=y
CONFIG_MKDIR=y
CONFIG_FEATURE_MKDIR_LONG_OPTIONS=y
CONFIG_MKFIFO=y
CONFIG_MKNOD=y
CONFIG_MV=y
CONFIG_FEATURE_MV_LONG_OPTIONS=y
CONFIG_NICE=y
CONFIG_NOHUP=y
CONFIG_OD=y
CONFIG_PRINTENV=y
CONFIG_PRINTF=y
CONFIG_PWD=y
CONFIG_READLINK=y
CONFIG_FEATURE_READLINK_FOLLOW=y
CONFIG_REALPATH=y
CONFIG_RM=y
CONFIG_RMDIR=y
CONFIG_FEATURE_RMDIR_LONG_OPTIONS=y
CONFIG_SEQ=y
CONFIG_SHA1SUM=y
CONFIG_SHA256SUM=y
CONFIG_SHA512SUM=y
CONFIG_SLEEP=y
CONFIG_FEATURE_FANCY_SLEEP=y
CONFIG_FEATURE_FLOAT_SLEEP=y
CONFIG_SORT=y
CONFIG_FEATURE_SORT_BIG=y
CONFIG_SPLIT=y
CONFIG_FEATURE_SPLIT_FANCY=y
CONFIG_STAT=y
CONFIG_FEATURE_STAT_FORMAT=y
CONFIG_STTY=y
CONFIG_SUM=y
CONFIG_SYNC=y
CONFIG_TAC=y
CONFIG_TAIL=y
CONFIG_FEATURE_FANCY_TAIL=y
CONFIG_TEE=y
# CONFIG_FEATURE_TEE_USE_BLOCK_IO is not set
CONFIG_TRUE=y
CONFIG_TTY=y
CONFIG_UNAME=y
CONFIG_UNEXPAND=y
CONFIG_FEATURE_UNEXPAND_LONG_OPTIONS=y
CONFIG_UNIQ=y
CONFIG_USLEEP=y
CONFIG_UUDECODE=y
CONFIG_UUENCODE=y
CONFIG_WC=y
CONFIG_FEATURE_WC_LARGE=y
CONFIG_WHOAMI=y
CONFIG_YES=y

#
# Common options for cp and mv
#
# CONFIG_FEATURE_PRESERVE_HARDLINKS is not set

#
# Common options for ls, more and telnet
#
CONFIG_FEATURE_AUTOWIDTH=y

#
# Common options for df, du, ls
#
CONFIG_FEATURE_HUMAN_READABLE=y

#
# Common options for md5sum, sha1sum, sha256sum, sha512sum
#
CONFIG_FEATURE_MD5_SHA1_SUM_CHECK=y

#
# Console Utilities
#
CONFIG_CHVT=y
CONFIG_FGCONSOLE=y
CONFIG_CLEAR=y
CONFIG_DEALLOCVT=y
CONFIG_DUMPKMAP=y
CONFIG_KBD_MODE=y
CONFIG_LOADFONT=y
CONFIG_LOADKMAP=y
CONFIG_OPENVT=y
CONFIG_RESET=y
CONFIG_RESIZE=y
CONFIG_FEATURE_RESIZE_PRINT=y
CONFIG_SETCONSOLE=y
CONFIG_FEATURE_SETCONSOLE_LONG_OPTIONS=y
CONFIG_SETFONT=y
CONFIG_FEATURE_SETFONT_TEXTUAL_MAP=y
CONFIG_DEFAULT_SETFONT_DIR=""
CONFIG_SETKEYCODES=y
CONFIG_SETLOGCONS=y
CONFIG_SHOWKEY=y

#
# Common options for loadfont and setfont
#
CONFIG_FEATURE_LOADFONT_PSF2=y
CONFIG_FEATURE_LOADFONT_RAW=y

#
# Debian Utilities
#
CONFIG_MKTEMP=y
CONFIG_PIPE_PROGRESS=y
CONFIG_RUN_PARTS=y
CONFIG_FEATURE_RUN_PARTS_LONG_OPTIONS=y
CONFIG_FEATURE_RUN_PARTS_FANCY=y
CONFIG_START_STOP_DAEMON=y
CONFIG_FEATURE_START_STOP_DAEMON_FANCY=y
CONFIG_FEATURE_START_STOP_DAEMON_LONG_OPTIONS=y
CONFIG_WHICH=y

#
# Editors
#
CONFIG_PATCH=y
CONFIG_VI=y
CONFIG_FEATURE_VI_MAX_LEN=4096
CONFIG_FEATURE_VI_8BIT=y
CONFIG_FEATURE_VI_COLON=y
CONFIG_FEATURE_VI_YANKMARK=y
CONFIG_FEATURE_VI_SEARCH=y
CONFIG_FEATURE_VI_REGEX_SEARCH=y
CONFIG_FEATURE_VI_USE_SIGNALS=y
CONFIG_FEATURE_VI_DOT_CMD=y
CONFIG_FEATURE_VI_READONLY=y
CONFIG_FEATURE_VI_SETOPTS=y
CONFIG_FEATURE_VI_SET=y
CONFIG_FEATURE_VI_WIN_RESIZE=y
CONFIG_FEATURE_VI_ASK_TERMINAL=y
CONFIG_FEATURE_VI_OPTIMIZE_CURSOR=y
# CONFIG_AWK is not set
# CONFIG_FEATURE_AWK_LIBM is not set
CONFIG_CMP=y
CONFIG_DIFF=y
CONFIG_FEATURE_DIFF_LONG_OPTIONS=y
CONFIG_FEATURE_DIFF_DIR=y
CONFIG_ED=y
CONFIG_SED=y
CONFIG_FEATURE_ALLOW_EXEC=y

#
# Finding Utilities
#
CONFIG_FIND=y
CONFIG_FEATURE_FIND_PRINT0=y
CONFIG_FEATURE_FIND_MTIME=y
CONFIG_FEATURE_FIND_MMIN=y
CONFIG_FEATURE_FIND_PERM=y
CONFIG_FEATURE_FIND_TYPE=y
CONFIG_FEATURE_FIND_XDEV=y
CONFIG_FEATURE_FIND_MAXDEPTH=y
CONFIG_FEATURE_FIND_NEWER=y
CONFIG_FEATURE_FIND_INUM=y
CONFIG_FEATURE_FIND_EXEC=y
CONFIG_FEATURE_FIND_USER=y
CONFIG_FEATURE_FIND_GROUP=y
CONFIG_FEATURE_FIND_NOT=y
CONFIG_FEATURE_FIND_DEPTH=y
CONFIG_FEATURE_FIND_PAREN=y
CONFIG_FEATURE_FIND_SIZE=y
CONFIG_FEATURE_FIND_PRUNE=y
CONFIG_FEATURE_FIND_DELETE=y
CONFIG_FEATURE_FIND_PATH=y
CONFIG_FEATURE_FIND_REGEX=y
# CONFIG_FEATURE_FIND_CONTEXT is not set
CONFIG_FEATURE_FIND_LINKS=y
CONFIG_GREP=y
CONFIG_FEATURE_GREP_EGREP_ALIAS=y
CONFIG_FEATURE_GREP_FGREP_ALIAS=y
CONFIG_FEATURE_GREP_CONTEXT=y
CONFIG_XARGS=y
CONFIG_FEATURE_XARGS_SUPPORT_CONFIRMATION=y
CONFIG_FEATURE_XARGS_SUPPORT_QUOTES=y
CONFIG_FEATURE_XARGS_SUPPORT_TERMOPT=y
CONFIG_FEATURE_XARGS_SUPPORT_ZERO_TERM=y

#
# Init Utilities
#
# CONFIG_BOOTCHARTD is not set
# CONFIG_FEATURE_BOOTCHARTD_BLOATED_HEADER is not set
# CONFIG_FEATURE_BOOTCHARTD_CONFIG_FILE is not set
CONFIG_HALT=y
# CONFIG_FEATURE_CALL_TELINIT is not set
CONFIG_TELINIT_PATH=""
CONFIG_INIT=y
CONFIG_FEATURE_USE_INITTAB=y
CONFIG_FEATURE_KILL_REMOVED=y
CONFIG_FEATURE_KILL_DELAY=0
# CONFIG_FEATURE_INIT_SCTTY is not set
# CONFIG_FEATURE_INIT_SYSLOG is not set
CONFIG_FEATURE_EXTRA_QUIET=y
# CONFIG_FEATURE_INIT_COREDUMPS is not set
# CONFIG_FEATURE_INITRD is not set
CONFIG_INIT_TERMINAL_TYPE="linux"
CONFIG_MESG=y
# CONFIG_FEATURE_MESG_ENABLE_ONLY_GROUP is not set

#
# Login/Password Management Utilities
#
# CONFIG_ADD_SHELL is not set
# CONFIG_REMOVE_SHELL is not set
CONFIG_FEATURE_SHADOWPASSWDS=y
CONFIG_USE_BB_PWD_GRP=y
CONFIG_USE_BB_SHADOW=y
CONFIG_USE_BB_CRYPT=y
CONFIG_USE_BB_CRYPT_SHA=y
CONFIG_ADDUSER=y
CONFIG_FEATURE_ADDUSER_LONG_OPTIONS=y
CONFIG_FEATURE_CHECK_NAMES=y
CONFIG_FIRST_SYSTEM_ID=100
CONFIG_LAST_SYSTEM_ID=999
CONFIG_ADDGROUP=y
CONFIG_FEATURE_ADDGROUP_LONG_OPTIONS=y
CONFIG_FEATURE_ADDUSER_TO_GROUP=y
CONFIG_DELUSER=y
CONFIG_DELGROUP=y
CONFIG_FEATURE_DEL_USER_FROM_GROUP=y
CONFIG_GETTY=y
CONFIG_LOGIN=y
CONFIG_LOGIN_SESSION_AS_CHILD=y
# CONFIG_PAM is not set
# CONFIG_LOGIN_SCRIPTS is not set
CONFIG_FEATURE_NOLOGIN=y
# CONFIG_FEATURE_SECURETTY is not set
CONFIG_PASSWD=y
# CONFIG_FEATURE_PASSWD_WEAK_CHECK is not set
CONFIG_CRYPTPW=y
CONFIG_CHPASSWD=y
CONFIG_FEATURE_DEFAULT_PASSWD_ALGO="md5"
CONFIG_SU=y
CONFIG_FEATURE_SU_SYSLOG=y
# CONFIG_FEATURE_SU_CHECKS_SHELLS is not set
CONFIG_SULOGIN=y
CONFIG_VLOCK=y

#
# Linux Ext2 FS Progs
#
# CONFIG_CHATTR is not set
CONFIG_FSCK=y
# CONFIG_LSATTR is not set
CONFIG_TUNE2FS=y

#
# Linux Module Utilities
#
CONFIG_MODINFO=y
# CONFIG_MODPROBE_SMALL is not set
# CONFIG_FEATURE_MODPROBE_SMALL_OPTIONS_ON_CMDLINE is not set
# CONFIG_FEATURE_MODPROBE_SMALL_CHECK_ALREADY_LOADED is not set
CONFIG_INSMOD=y
CONFIG_RMMOD=y
CONFIG_LSMOD=y
CONFIG_FEATURE_LSMOD_PRETTY_2_6_OUTPUT=y
CONFIG_MODPROBE=y
CONFIG_FEATURE_MODPROBE_BLACKLIST=y
CONFIG_DEPMOD=y

#
# Options common to multiple modutils
#
# CONFIG_FEATURE_2_4_MODULES is not set
# CONFIG_FEATURE_INSMOD_TRY_MMAP is not set
# CONFIG_FEATURE_INSMOD_VERSION_CHECKING is not set
# CONFIG_FEATURE_INSMOD_KSYMOOPS_SYMBOLS is not set
# CONFIG_FEATURE_INSMOD_LOADINKMEM is not set
# CONFIG_FEATURE_INSMOD_LOAD_MAP is not set
# CONFIG_FEATURE_INSMOD_LOAD_MAP_FULL is not set
CONFIG_FEATURE_CHECK_TAINTED_MODULE=y
CONFIG_FEATURE_MODUTILS_ALIAS=y
CONFIG_FEATURE_MODUTILS_SYMBOLS=y
CONFIG_DEFAULT_MODULES_DIR="/lib/modules"
CONFIG_DEFAULT_DEPMOD_FILE="modules.dep"

#
# Linux System Utilities
#
CONFIG_BLOCKDEV=y
CONFIG_MDEV=y
CONFIG_FEATURE_MDEV_CONF=y
CONFIG_FEATURE_MDEV_RENAME=y
CONFIG_FEATURE_MDEV_RENAME_REGEXP=y
CONFIG_FEATURE_MDEV_EXEC=y
CONFIG_FEATURE_MDEV_LOAD_FIRMWARE=y
CONFIG_REV=y
CONFIG_ACPID=y
CONFIG_FEATURE_ACPID_COMPAT=y
CONFIG_BLKID=y
CONFIG_FEATURE_BLKID_TYPE=y
CONFIG_DMESG=y
CONFIG_FEATURE_DMESG_PRETTY=y
CONFIG_FBSET=y
CONFIG_FEATURE_FBSET_FANCY=y
CONFIG_FEATURE_FBSET_READMODE=y
CONFIG_FDFLUSH=y
CONFIG_FDFORMAT=y
CONFIG_FDISK=y
# CONFIG_FDISK_SUPPORT_LARGE_DISKS is not set
CONFIG_FEATURE_FDISK_WRITABLE=y
CONFIG_FEATURE_AIX_LABEL=y
CONFIG_FEATURE_SGI_LABEL=y
CONFIG_FEATURE_SUN_LABEL=y
CONFIG_FEATURE_OSF_LABEL=y
CONFIG_FEATURE_GPT_LABEL=y
CONFIG_FEATURE_FDISK_ADVANCED=y
CONFIG_FINDFS=y
CONFIG_FLOCK=y
CONFIG_FREERAMDISK=y
# CONFIG_FSCK_MINIX is not set
CONFIG_MKFS_EXT2=y
# CONFIG_MKFS_MINIX is not set
# CONFIG_FEATURE_MINIX2 is not set
CONFIG_MKFS_REISER=y
CONFIG_MKFS_VFAT=y
CONFIG_GETOPT=y
CONFIG_FEATURE_GETOPT_LONG=y
CONFIG_HEXDUMP=y
CONFIG_FEATURE_HEXDUMP_REVERSE=y
CONFIG_HD=y
CONFIG_HWCLOCK=y
CONFIG_FEATURE_HWCLOCK_LONG_OPTIONS=y
# CONFIG_FEATURE_HWCLOCK_ADJTIME_FHS is not set
# CONFIG_IPCRM is not set
# CONFIG_IPCS is not set
CONFIG_LOSETUP=y
CONFIG_LSPCI=y
CONFIG_LSUSB=y
CONFIG_MKSWAP=y
CONFIG_FEATURE_MKSWAP_UUID=y
CONFIG_MORE=y
CONFIG_MOUNT=y
CONFIG_FEATURE_MOUNT_FAKE=y
CONFIG_FEATURE_MOUNT_VERBOSE=y
# CONFIG_FEATURE_MOUNT_HELPERS is not set
CONFIG_FEATURE_MOUNT_LABEL=y
CONFIG_FEATURE_MOUNT_NFS=y
CONFIG_FEATURE_MOUNT_CIFS=y
CONFIG_FEATURE_MOUNT_FLAGS=y
CONFIG_FEATURE_MOUNT_FSTAB=y
CONFIG_PIVOT_ROOT=y
CONFIG_RDATE=y
CONFIG_RDEV=y
# CONFIG_READPROFILE is not set
CONFIG_RTCWAKE=y
# CONFIG_SCRIPT is not set
# CONFIG_SCRIPTREPLAY is not set
# CONFIG_SETARCH is not set
CONFIG_SWAPONOFF=y
CONFIG_FEATURE_SWAPON_PRI=y
CONFIG_SWITCH_ROOT=y
CONFIG_UMOUNT=y
CONFIG_FEATURE_UMOUNT_ALL=y

#
# Common options for mount/umount
#
CONFIG_FEATURE_MOUNT_LOOP=y
CONFIG_FEATURE_MOUNT_LOOP_CREATE=y
# CONFIG_FEATURE_MTAB_SUPPORT is not set
CONFIG_VOLUMEID=y

#
# Filesystem/Volume identification
#
CONFIG_FEATURE_VOLUMEID_EXT=y
CONFIG_FEATURE_VOLUMEID_BTRFS=y
CONFIG_FEATURE_VOLUMEID_REISERFS=y
CONFIG_FEATURE_VOLUMEID_FAT=y
CONFIG_FEATURE_VOLUMEID_HFS=y
CONFIG_FEATURE_VOLUMEID_JFS=y
CONFIG_FEATURE_VOLUMEID_XFS=y
CONFIG_FEATURE_VOLUMEID_NTFS=y
CONFIG_FEATURE_VOLUMEID_ISO9660=y
CONFIG_FEATURE_VOLUMEID_UDF=y
CONFIG_FEATURE_VOLUMEID_LUKS=y
CONFIG_FEATURE_VOLUMEID_LINUXSWAP=y
CONFIG_FEATURE_VOLUMEID_CRAMFS=y
CONFIG_FEATURE_VOLUMEID_ROMFS=y
CONFIG_FEATURE_VOLUMEID_SYSV=y
CONFIG_FEATURE_VOLUMEID_OCFS2=y
CONFIG_FEATURE_VOLUMEID_LINUXRAID=y

#
# Miscellaneous Utilities
#
# CONFIG_CONSPY is not set
CONFIG_LESS=y
CONFIG_FEATURE_LESS_MAXLINES=9999999
CONFIG_FEATURE_LESS_BRACKETS=y
CONFIG_FEATURE_LESS_FLAGS=y
CONFIG_FEATURE_LESS_MARKS=y
CONFIG_FEATURE_LESS_REGEXP=y
CONFIG_FEATURE_LESS_WINCH=y
CONFIG_FEATURE_LESS_ASK_TERMINAL=y
CONFIG_FEATURE_LESS_DASHCMD=y
CONFIG_FEATURE_LESS_LINENUMS=y
# CONFIG_NANDWRITE is not set
# CONFIG_NANDDUMP is not set
CONFIG_SETSERIAL=y
# CONFIG_UBIATTACH is not set
# CONFIG_UBIDETACH is not set
# CONFIG_UBIMKVOL is not set
# CONFIG_UBIRMVOL is not set
# CONFIG_UBIRSVOL is not set
# CONFIG_UBIUPDATEVOL is not set
# CONFIG_ADJTIMEX is not set
CONFIG_BBCONFIG=y
# CONFIG_FEATURE_COMPRESS_BBCONFIG is not set
CONFIG_BEEP=y
CONFIG_FEATURE_BEEP_FREQ=4000
CONFIG_FEATURE_BEEP_LENGTH_MS=300
# CONFIG_CHAT is not set
# CONFIG_FEATURE_CHAT_NOFAIL is not set
# CONFIG_FEATURE_CHAT_TTY_HIFI is not set
# CONFIG_FEATURE_CHAT_IMPLICIT_CR is not set
# CONFIG_FEATURE_CHAT_SWALLOW_OPTS is not set
# CONFIG_FEATURE_CHAT_SEND_ESCAPES is not set
# CONFIG_FEATURE_CHAT_VAR_ABORT_LEN is not set
# CONFIG_FEATURE_CHAT_CLR_ABORT is not set
# CONFIG_CHRT is not set
CONFIG_CROND=y
CONFIG_FEATURE_CROND_D=y
# CONFIG_FEATURE_CROND_CALL_SENDMAIL is not set
CONFIG_FEATURE_CROND_DIR="/var/spool/cron"
CONFIG_CRONTAB=y
CONFIG_DC=y
# CONFIG_FEATURE_DC_LIBM is not set
# CONFIG_DEVFSD is not set
# CONFIG_DEVFSD_MODLOAD is not set
# CONFIG_DEVFSD_FG_NP is not set
# CONFIG_DEVFSD_VERBOSE is not set
# CONFIG_FEATURE_DEVFS is not set
CONFIG_DEVMEM=y
CONFIG_EJECT=y
CONFIG_FEATURE_EJECT_SCSI=y
CONFIG_FBSPLASH=y
CONFIG_FLASHCP=y
CONFIG_FLASH_LOCK=y
CONFIG_FLASH_UNLOCK=y
CONFIG_FLASH_ERASEALL=y
CONFIG_IONICE=y
CONFIG_INOTIFYD=y
# CONFIG_LAST is not set
# CONFIG_FEATURE_LAST_SMALL is not set
# CONFIG_FEATURE_LAST_FANCY is not set
CONFIG_HDPARM=y
CONFIG_FEATURE_HDPARM_GET_IDENTITY=y
# CONFIG_FEATURE_HDPARM_HDIO_SCAN_HWIF is not set
# CONFIG_FEATURE_HDPARM_HDIO_UNREGISTER_HWIF is not set
# CONFIG_FEATURE_HDPARM_HDIO_DRIVE_RESET is not set
# CONFIG_FEATURE_HDPARM_HDIO_TRISTATE_HWIF is not set
CONFIG_FEATURE_HDPARM_HDIO_GETSET_DMA=y
CONFIG_MAKEDEVS=y
# CONFIG_FEATURE_MAKEDEVS_LEAF is not set
CONFIG_FEATURE_MAKEDEVS_TABLE=y
# CONFIG_MAN is not set
CONFIG_MICROCOM=y
CONFIG_MOUNTPOINT=y
# CONFIG_MT is not set
# CONFIG_RAIDAUTORUN is not set
CONFIG_READAHEAD=y
CONFIG_RFKILL=y
# CONFIG_RUNLEVEL is not set
# CONFIG_RX is not set
# CONFIG_SETSID is not set
CONFIG_STRINGS=y
# CONFIG_TASKSET is not set
# CONFIG_FEATURE_TASKSET_FANCY is not set
CONFIG_TIME=y
CONFIG_TIMEOUT=y
CONFIG_TTYSIZE=y
CONFIG_VOLNAME=y
# CONFIG_WALL is not set
# CONFIG_WATCHDOG is not set

#
# Networking Utilities
#
CONFIG_NAMEIF=y
CONFIG_FEATURE_NAMEIF_EXTENDED=y
# CONFIG_NBDCLIENT is not set
CONFIG_NC=y
CONFIG_NC_SERVER=y
CONFIG_NC_EXTRA=y
# CONFIG_NC_110_COMPAT is not set
CONFIG_PING=y
CONFIG_PING6=y
CONFIG_FEATURE_FANCY_PING=y
# CONFIG_WHOIS is not set
CONFIG_FEATURE_IPV6=y
# CONFIG_FEATURE_UNIX_LOCAL is not set
CONFIG_FEATURE_PREFER_IPV4_ADDRESS=y
# CONFIG_VERBOSE_RESOLUTION_ERRORS is not set
# CONFIG_ARP is not set
# CONFIG_ARPING is not set
# CONFIG_BRCTL is not set
# CONFIG_FEATURE_BRCTL_FANCY is not set
# CONFIG_FEATURE_BRCTL_SHOW is not set
# CONFIG_DNSD is not set
# CONFIG_ETHER_WAKE is not set
# CONFIG_FAKEIDENTD is not set
# CONFIG_FTPD is not set
# CONFIG_FEATURE_FTP_WRITE is not set
# CONFIG_FEATURE_FTPD_ACCEPT_BROKEN_LIST is not set
CONFIG_FTPGET=y
CONFIG_FTPPUT=y
CONFIG_FEATURE_FTPGETPUT_LONG_OPTIONS=y
CONFIG_HOSTNAME=y
CONFIG_HTTPD=y
CONFIG_FEATURE_HTTPD_RANGES=y
# CONFIG_FEATURE_HTTPD_USE_SENDFILE is not set
CONFIG_FEATURE_HTTPD_SETUID=y
CONFIG_FEATURE_HTTPD_BASIC_AUTH=y
CONFIG_FEATURE_HTTPD_AUTH_MD5=y
CONFIG_FEATURE_HTTPD_CGI=y
CONFIG_FEATURE_HTTPD_CONFIG_WITH_SCRIPT_INTERPR=y
CONFIG_FEATURE_HTTPD_SET_REMOTE_PORT_TO_ENV=y
CONFIG_FEATURE_HTTPD_ENCODE_URL_STR=y
CONFIG_FEATURE_HTTPD_ERROR_PAGES=y
CONFIG_FEATURE_HTTPD_PROXY=y
CONFIG_FEATURE_HTTPD_GZIP=y
CONFIG_IFCONFIG=y
CONFIG_FEATURE_IFCONFIG_STATUS=y
CONFIG_FEATURE_IFCONFIG_SLIP=y
CONFIG_FEATURE_IFCONFIG_MEMSTART_IOADDR_IRQ=y
CONFIG_FEATURE_IFCONFIG_HW=y
CONFIG_FEATURE_IFCONFIG_BROADCAST_PLUS=y
# CONFIG_IFENSLAVE is not set
CONFIG_IFPLUGD=y
CONFIG_IFUPDOWN=y
CONFIG_IFUPDOWN_IFSTATE_PATH="/var/run/ifstate"
CONFIG_FEATURE_IFUPDOWN_IP=y
CONFIG_FEATURE_IFUPDOWN_IP_BUILTIN=y
# CONFIG_FEATURE_IFUPDOWN_IFCONFIG_BUILTIN is not set
CONFIG_FEATURE_IFUPDOWN_IPV4=y
CONFIG_FEATURE_IFUPDOWN_IPV6=y
CONFIG_FEATURE_IFUPDOWN_MAPPING=y
CONFIG_FEATURE_IFUPDOWN_EXTERNAL_DHCP=y
# CONFIG_INETD is not set
# CONFIG_FEATURE_INETD_SUPPORT_BUILTIN_ECHO is not set
# CONFIG_FEATURE_INETD_SUPPORT_BUILTIN_DISCARD is not set
# CONFIG_FEATURE_INETD_SUPPORT_BUILTIN_TIME is not set
# CONFIG_FEATURE_INETD_SUPPORT_BUILTIN_DAYTIME is not set
# CONFIG_FEATURE_INETD_SUPPORT_BUILTIN_CHARGEN is not set
# CONFIG_FEATURE_INETD_RPC is not set
CONFIG_IP=y
CONFIG_FEATURE_IP_ADDRESS=y
CONFIG_FEATURE_IP_LINK=y
CONFIG_FEATURE_IP_ROUTE=y
CONFIG_FEATURE_IP_TUNNEL=y
CONFIG_FEATURE_IP_RULE=y
CONFIG_FEATURE_IP_SHORT_FORMS=y
# CONFIG_FEATURE_IP_RARE_PROTOCOLS is not set
CONFIG_IPADDR=y
CONFIG_IPLINK=y
CONFIG_IPROUTE=y
CONFIG_IPTUNNEL=y
CONFIG_IPRULE=y
CONFIG_IPCALC=y
CONFIG_FEATURE_IPCALC_FANCY=y
CONFIG_FEATURE_IPCALC_LONG_OPTIONS=y
CONFIG_NETSTAT=y
CONFIG_FEATURE_NETSTAT_WIDE=y
CONFIG_FEATURE_NETSTAT_PRG=y
CONFIG_NSLOOKUP=y
# CONFIG_NTPD is not set
# CONFIG_FEATURE_NTPD_SERVER is not set
CONFIG_PSCAN=y
CONFIG_ROUTE=y
# CONFIG_SLATTACH is not set
# CONFIG_TCPSVD is not set
CONFIG_TELNET=y
CONFIG_FEATURE_TELNET_TTYPE=y
CONFIG_FEATURE_TELNET_AUTOLOGIN=y
# CONFIG_TELNETD is not set
# CONFIG_FEATURE_TELNETD_STANDALONE is not set
# CONFIG_FEATURE_TELNETD_INETD_WAIT is not set
CONFIG_TFTP=y
# CONFIG_TFTPD is not set

#
# Common options for tftp/tftpd
#
CONFIG_FEATURE_TFTP_GET=y
CONFIG_FEATURE_TFTP_PUT=y
CONFIG_FEATURE_TFTP_BLOCKSIZE=y
CONFIG_FEATURE_TFTP_PROGRESS_BAR=y
# CONFIG_TFTP_DEBUG is not set
CONFIG_TRACEROUTE=y
CONFIG_TRACEROUTE6=y
CONFIG_FEATURE_TRACEROUTE_VERBOSE=y
CONFIG_FEATURE_TRACEROUTE_SOURCE_ROUTE=y
CONFIG_FEATURE_TRACEROUTE_USE_ICMP=y
# CONFIG_TUNCTL is not set
# CONFIG_FEATURE_TUNCTL_UG is not set
CONFIG_UDHCPC6=y
CONFIG_UDHCPD=y
CONFIG_DHCPRELAY=y
CONFIG_DUMPLEASES=y
CONFIG_FEATURE_UDHCPD_WRITE_LEASES_EARLY=y
# CONFIG_FEATURE_UDHCPD_BASE_IP_ON_MAC is not set
CONFIG_DHCPD_LEASES_FILE="/var/lib/misc/udhcpd.leases"
CONFIG_UDHCPC=y
CONFIG_FEATURE_UDHCPC_ARPING=y
CONFIG_FEATURE_UDHCP_PORT=y
CONFIG_UDHCP_DEBUG=0
CONFIG_FEATURE_UDHCP_RFC3397=y
CONFIG_FEATURE_UDHCP_8021Q=y
CONFIG_UDHCPC_DEFAULT_SCRIPT="/usr/share/udhcpc/default.script"
CONFIG_UDHCPC_SLACK_FOR_BUGGY_SERVERS=80
CONFIG_IFUPDOWN_UDHCPC_CMD_OPTIONS="-R -n"
# CONFIG_UDPSVD is not set
# CONFIG_VCONFIG is not set
CONFIG_WGET=y
CONFIG_FEATURE_WGET_STATUSBAR=y
CONFIG_FEATURE_WGET_AUTHENTICATION=y
CONFIG_FEATURE_WGET_LONG_OPTIONS=y
CONFIG_FEATURE_WGET_TIMEOUT=y
# CONFIG_ZCIP is not set

#
# Print Utilities
#
# CONFIG_LPD is not set
# CONFIG_LPR is not set
# CONFIG_LPQ is not set

#
# Mail Utilities
#
# CONFIG_MAKEMIME is not set
CONFIG_FEATURE_MIME_CHARSET=""
# CONFIG_POPMAILDIR is not set
# CONFIG_FEATURE_POPMAILDIR_DELIVERY is not set
# CONFIG_REFORMIME is not set
# CONFIG_FEATURE_REFORMIME_COMPAT is not set
# CONFIG_SENDMAIL is not set

#
# Process Utilities
#
CONFIG_IOSTAT=y
CONFIG_LSOF=y
CONFIG_MPSTAT=y
# CONFIG_NMETER is not set
CONFIG_PMAP=y
CONFIG_POWERTOP=y
CONFIG_PSTREE=y
CONFIG_PWDX=y
# CONFIG_SMEMCAP is not set
CONFIG_UPTIME=y
# CONFIG_FEATURE_UPTIME_UTMP_SUPPORT is not set
CONFIG_FREE=y
CONFIG_FUSER=y
CONFIG_KILL=y
CONFIG_KILLALL=y
# CONFIG_KILLALL5 is not set
CONFIG_PGREP=y
CONFIG_PIDOF=y
CONFIG_FEATURE_PIDOF_SINGLE=y
CONFIG_FEATURE_PIDOF_OMIT=y
CONFIG_PKILL=y
CONFIG_PS=y
# CONFIG_FEATURE_PS_WIDE is not set
# CONFIG_FEATURE_PS_LONG is not set
CONFIG_FEATURE_PS_TIME=y
CONFIG_FEATURE_PS_ADDITIONAL_COLUMNS=y
# CONFIG_FEATURE_PS_UNUSUAL_SYSTEMS is not set
CONFIG_RENICE=y
CONFIG_BB_SYSCTL=y
CONFIG_TOP=y
CONFIG_FEATURE_TOP_CPU_USAGE_PERCENTAGE=y
CONFIG_FEATURE_TOP_CPU_GLOBAL_PERCENTS=y
CONFIG_FEATURE_TOP_SMP_CPU=y
# CONFIG_FEATURE_TOP_DECIMALS is not set
CONFIG_FEATURE_TOP_SMP_PROCESS=y
CONFIG_FEATURE_TOPMEM=y
CONFIG_FEATURE_SHOW_THREADS=y
CONFIG_WATCH=y

#
# Runit Utilities
#
# CONFIG_RUNSV is not set
# CONFIG_RUNSVDIR is not set
# CONFIG_FEATURE_RUNSVDIR_LOG is not set
# CONFIG_SV is not set
CONFIG_SV_DEFAULT_SERVICE_DIR=""
# CONFIG_SVLOGD is not set
# CONFIG_CHPST is not set
# CONFIG_SETUIDGID is not set
# CONFIG_ENVUIDGID is not set
# CONFIG_ENVDIR is not set
# CONFIG_SOFTLIMIT is not set
# CONFIG_CHCON is not set
# CONFIG_FEATURE_CHCON_LONG_OPTIONS is not set
# CONFIG_GETENFORCE is not set
# CONFIG_GETSEBOOL is not set
# CONFIG_LOAD_POLICY is not set
# CONFIG_MATCHPATHCON is not set
# CONFIG_RESTORECON is not set
# CONFIG_RUNCON is not set
# CONFIG_FEATURE_RUNCON_LONG_OPTIONS is not set
# CONFIG_SELINUXENABLED is not set
# CONFIG_SETENFORCE is not set
# CONFIG_SETFILES is not set
# CONFIG_FEATURE_SETFILES_CHECK_OPTION is not set
# CONFIG_SETSEBOOL is not set
# CONFIG_SESTATUS is not set

#
# Shells
#
CONFIG_ASH=y
CONFIG_ASH_BASH_COMPAT=y
# CONFIG_ASH_IDLE_TIMEOUT is not set
CONFIG_ASH_JOB_CONTROL=y
CONFIG_ASH_ALIAS=y
CONFIG_ASH_GETOPTS=y
CONFIG_ASH_BUILTIN_ECHO=y
CONFIG_ASH_BUILTIN_PRINTF=y
CONFIG_ASH_BUILTIN_TEST=y
CONFIG_ASH_CMDCMD=y
# CONFIG_ASH_MAIL is not set
CONFIG_ASH_OPTIMIZE_FOR_SIZE=y
CONFIG_ASH_RANDOM_SUPPORT=y
CONFIG_ASH_EXPAND_PRMT=y
# CONFIG_CTTYHACK is not set
# CONFIG_HUSH is not set
# CONFIG_HUSH_BASH_COMPAT is not set
# CONFIG_HUSH_BRACE_EXPANSION is not set
# CONFIG_HUSH_HELP is not set
# CONFIG_HUSH_INTERACTIVE is not set
# CONFIG_HUSH_SAVEHISTORY is not set
# CONFIG_HUSH_JOB is not set
# CONFIG_HUSH_TICK is not set
# CONFIG_HUSH_IF is not set
# CONFIG_HUSH_LOOPS is not set
# CONFIG_HUSH_CASE is not set
# CONFIG_HUSH_FUNCTIONS is not set
# CONFIG_HUSH_LOCAL is not set
# CONFIG_HUSH_RANDOM_SUPPORT is not set
# CONFIG_HUSH_EXPORT_N is not set
# CONFIG_HUSH_MODE_X is not set
# CONFIG_MSH is not set
CONFIG_FEATURE_SH_IS_ASH=y
# CONFIG_FEATURE_SH_IS_HUSH is not set
# CONFIG_FEATURE_SH_IS_NONE is not set
# CONFIG_FEATURE_BASH_IS_ASH is not set
# CONFIG_FEATURE_BASH_IS_HUSH is not set
CONFIG_FEATURE_BASH_IS_NONE=y
CONFIG_SH_MATH_SUPPORT=y
CONFIG_SH_MATH_SUPPORT_64=y
CONFIG_FEATURE_SH_EXTRA_QUIET=y
# CONFIG_FEATURE_SH_STANDALONE is not set
# CONFIG_FEATURE_SH_NOFORK is not set
CONFIG_FEATURE_SH_HISTFILESIZE=y

#
# System Logging Utilities
#
CONFIG_SYSLOGD=y
CONFIG_FEATURE_ROTATE_LOGFILE=y
# CONFIG_FEATURE_REMOTE_LOG is not set
CONFIG_FEATURE_SYSLOGD_DUP=y
# CONFIG_FEATURE_SYSLOGD_CFG is not set
CONFIG_FEATURE_SYSLOGD_READ_BUFFER_SIZE=256
CONFIG_FEATURE_IPC_SYSLOG=y
CONFIG_FEATURE_IPC_SYSLOG_BUFFER_SIZE=16
CONFIG_LOGREAD=y
# CONFIG_FEATURE_LOGREAD_REDUCED_LOCKING is not set
CONFIG_KLOGD=y
CONFIG_FEATURE_KLOGD_KLOGCTL=y
CONFIG_LOGGER=y
CONFIG_END
	[ $? -ne 0  ] && return 1

	# build the package
	make -j $BUILD_THREADS
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the package
	make install
	[ $? -ne 0 ] && return 1

	# make sure /bin/busybox has the right permissions
	chmod 4755 $INSTALL_DIR/bin/busybox
	[ $? -ne 0 ] && return 1

	# add /etc/busybox.conf
	mkdir $INSTALL_DIR/etc
	[ $? -ne 0 ] && return 1
	cat << END > $INSTALL_DIR/etc/busybox.conf
[SUID]
su = ssx
sulogin = ssx
END
	chmod 600 $INSTALL_DIR/etc/busybox.conf
	[ $? -ne 0 ] && return 1

	return 0
}
