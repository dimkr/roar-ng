#!/bin/sh

PKG_NAME="dropbear"
PKG_VER="2011.54"
PKG_REV="1"
PKG_DESC="SSH2 server and client"
PKG_CAT="Network"
PKG_DEPS=""

# the programs to build
PROGRAMS="dbclient dropbearkey"

download() {
	[ -f $PKG_NAME-$PKG_VER.tar.bz2 ] && return 0
	# download the sources tarball
	download_file http://matt.ucc.asn.au/dropbear/releases/$PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1
	return 0
}

build() {
	# extract the sources
	tar -xjvf $PKG_NAME-$PKG_VER.tar.bz2
	[ $? -ne 0 ] && return 1

	cd $PKG_NAME-$PKG_VER

	# configure the package
	./configure $AUTOTOOLS_BASE_OPTS \
	            --disable-pam \
	            --disable-syslog \
	            --disable-lastlog \
	            --disable-utmp \
	            --disable-utmpx \
	            --disable-wtmp \
	            --disable-wtmpx
	[ $? -ne 0 ] && return 1

	# set the xauth path
	sed -i s~'/usr/bin/X11/xauth'~"$(which xauth)"~ options.h
	[ $? -ne 0 ] && return 1
	
	# set the key paths
	sed -i s~/etc/dropbear~"/$CONF_DIR/dropbear"~g options.h
	[ $? -ne 0 ] && return 1
	
	# build the package
	make -j $BUILD_THREADS PROGRAMS="dropbear $PROGRAMS" MULTI=1
	[ $? -ne 0 ] && return 1

	return 0
}

package() {
	# install the multi-call binary
	install -D -m755 dropbearmulti $INSTALL_DIR/$BIN_DIR/dropbear
	[ $? -ne 0 ] && return 1

	# add the configuration directory
	mkdir -p $INSTALL_DIR/$CONF_DIR/dropbear
	[ $? -ne 0 ] && return 1

	# create symlinks to the multi-call binary
	for i in $PROGRAMS ssh
	do
		ln -s dropbear $INSTALL_DIR/$BIN_DIR/$i
		[ $? -ne 0 ] && return 1
	done

	# install the man page
	install -D -m644 dbclient.1 $INSTALL_DIR/$MAN_DIR/man1/dhclient.1
	[ $? -ne 0 ] && return 1

	# add an init script
	mkdir -p $INSTALL_DIR/$INIT_SCRIPT_DIR
	[ $? -ne 0 ] && return 1
	cat << END > $INSTALL_DIR/$INIT_SCRIPT_DIR/dropbear
#!/bin/dash

# /etc/init.d/dropbear: a Dropbear init script

case "\$1" in

	start)
		echo -n "Starting Dropbear ..."
		
		# generate the keys
		for i in rsa dss
		do
			[ -f /$CONF_DIR/dropbear/dropbear_${i}_host_key ] && continue
			dropbearkey -t \$i -f /$CONF_DIR/dropbear/dropbear_\${i}_host_key
			if [ \$? -ne 0 ]
			then
				echo "Error: failed to generate the \$(echo \$i | tr \[:lower:\] \[:upper:\]) key."
				exit 1
			fi
		done

		# start the server
		dropbear -P /$VAR_DIR/run/dropbear.pid
		echo " done"
		exit \$?
		;;

	stop)
		echo -n "Stopping Dropbear ..."
		kill \$(pidof dropbear)
		success=\$?
		[ -f /$VAR_DIR/run/dropbear.pid ] && rm -f /$VAR_DIR/run/dropbear.pid
		echo " done"
		exit \$success
		;;

	restart)
		"\$0" stop
		"\$0" start
		;;

	*)
		echo "dropbear {start|stop|restart}"
		exit 1
		;;

esac
END
	[ $? -ne 0 ] && return 1
	chmod 755 $INSTALL_DIR/$INIT_SCRIPT_DIR/dropbear
	[ $? -ne 0 ] && return 1

	# install the license
	install -D -m644 LICENSE $INSTALL_DIR/$LEGAL_DIR/$PKG_NAME/LICENSE
	[ $? -ne 0 ] && return 1

	return 0
}
