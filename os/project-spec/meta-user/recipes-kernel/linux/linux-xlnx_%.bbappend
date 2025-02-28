SRC_URI += "file://bsp.cfg"

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI += "file://user.cfg"
FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

