SRC_URI:append = " file://platform-top.h"
SRC_URI += "file://bsp.cfg"

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

do_configure:append () {
	install ${WORKDIR}/platform-top.h ${S}/include/configs/
}


