#!/bin/sh

# include the distribution information file
. ./etc/distrorc

echo "Generating the distribution documentation"

pages=""
for i in $(find ./usr/share/doc/distro -type f -name '*.html')
do
	sed -e s~DISTRO_NAME~"$DISTRO_NAME"~g \
	    -e s~DISTRO_VERSION~"$DISTRO_VERSION"~g \
	    -i $i
	pages="$pages
		<li><a href=\"${i##*/}\">$(cat $i | grep '<title>' | cut -f 2 -d \> | cut -f 1 -d \<)</a></li>"
done

# create the help index
cat << EOF > ./usr/share/doc/distro/index.html
<!DOCTYPE HTML>
<html>
<head>
<title>$DISTRO_NAME Documentation</title>
<meta name="description" content="$DISTRO_NAME Documentation" />
<meta http-equiv="content-type" content="text/html;charset=UTF-8" />
<LINK href="style.css" rel="stylesheet" type="text/css">
</head>
<body>
<table>
	<tr>
		<td><img src="/usr/share/pixmaps/distro.png"></td>
		<td><span id="title">$DISTRO_NAME Documentation</span></td>
	</tr>
</table>
<ul>
$pages
</ul>
</body>
</html>
EOF
chmod 644 ./usr/share/doc/distro/index.html
