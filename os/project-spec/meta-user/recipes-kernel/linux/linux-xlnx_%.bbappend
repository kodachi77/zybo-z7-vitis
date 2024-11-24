FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " file://bsp.cfg"
SRC_URI += "file://devtool-fragment.cfg \
            file://user_2024-11-24-19-39-00.cfg \
            "
SRC_URI += "file://user_2021-09-16-08-08-00.cfg \
           "

KERNEL_FEATURES:append = " bsp.cfg"
