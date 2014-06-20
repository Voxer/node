#!/usr/bin/env bash
#
# Voxer build script
#
# Author: Dave Eddy <dave@daveeddy.com>
# Date: 6/19/14

out=$1
arch=${2:-x64}

fatal() {
	echo "$@" >&2
	exit 1
}

if [[ -z $out ]]; then
	fatal 'error: out directory must be specified as the first argument'
fi


configure_opts=()
case "$arch" in
	x86) configuret_opts+=(--dest-cpu=ia32);;
	x64) ;;
	*) fatal "error: unknown arch '$arch'"
esac

case "$(uname)" in
	SunOS)
		configure_opts+=(--prefix=/opt/local --with-dtrace)
		;;
esac

export DESTDIR=$out
./configure "${configure_opts[@]}" >/dev/null || fatal 'failed to configure'
make -j 8 &> /dev/null                        || fatal 'failed to run `make`'
make install > /dev/null                      || exit 1

cd "$out" || exit 1
mv opt/local/* ./
rm -r opt/

echo "node built in $SECONDS seconds, saved to $out"
sha256sum bin/node
