# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/gtk-engines-murrine/gtk-engines-murrine-0.90.3-r1.ebuild,v 1.7 2010/02/14 06:23:53 nirbheek Exp $

EAPI="2"

inherit eutils gnome.org versionator

MY_PN="equinox"
THEME_ARCHIVE="${MY_PN}-themes-${PV}.tar.gz"
DESCRIPTION="A heavily modified version of the beautiful Aurora engine (1.4)"

HOMEPAGE="http://gnome-look.org/content/show.php/Equinox+Gtk+Engine?content=121881"
SRC_URI="http://gnome-look.org/CONTENT/content-files/121881-${MY_PN}-$(get_version_component_range 1-2).tar.gz
         http://gnome-look.org/CONTENT/content-files/140449-${THEME_ARCHIVE}
		 http://gnome-look.org/CONTENT/content-files/140448-${MY_PN}-themes-1.30.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux"
IUSE="+themes"

RDEPEND=">=x11-libs/gtk+-2.12"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.37.1
	sys-devel/gettext
	dev-util/pkgconfig"

S="${WORKDIR}/${MY_PN}-$(get_version_component_range 1-2)"

src_prepare() {
	epatch ${FILESDIR}/${P}-glib-2.31.patch
}

src_configure() {
	econf --enable-animation
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"
	if use themes;then
		dodir /usr/share/themes
		mkdir "${WORKDIR}/themes"
		mv "${WORKDIR}/Equinox"* "${WORKDIR}/themes"
		cd "${WORKDIR}/themes"
		for DIR in *;do
			if [ -d "${DIR}" ];then
				cp -dr "${DIR}" "${D}/usr/share/themes"
			fi
		done
	fi

}
