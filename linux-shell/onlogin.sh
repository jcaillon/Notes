#!/bin/sh
# This script is called from /etc/profile
# $(dirname ${0}) can't be used because this script is sourced in another one so $(dirname) would reference the wrong script.

pushd /exploit/scripts 1>/dev/null 2>/dev/null
. /exploit/scripts/source-init-session.sh
popd 1>/dev/null 2>/dev/null
