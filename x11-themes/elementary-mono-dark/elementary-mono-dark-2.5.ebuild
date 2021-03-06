# Copyright 1999-2006 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-themes/tango-icon-theme/tango-icon-theme-0.7.2.ebuild,v 1.3 2006/06/02 12:51:20 corsair Exp $

inherit eutils

DESCRIPTION="elementary icons is an icon theme designed to be smooth, sexy, clear, and efficient"
HOMEPAGE="https://launchpad.net/elementaryicons"
SRC_URI="http://code.launchpad.net/elementaryicons/${PV:0:1}.0/${PV}/+download/${PN}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~ppc ppc64 ~sparc ~x86"

RDEPEND="x11-themes/elementary-icon-theme"

DEPEND="${RDEPEND}"

S="${WORKDIR}"

src_install() {
	dodir /usr/share/icons
	for THEME in elementary-mono-dark ; do
		cp -R "${THEME}" "${D}"/usr/share/icons/
	done
}
