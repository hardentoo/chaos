# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

# require python-2 (min version 2.5) with sqlite USE flag
EAPI="3"

PYTHON_DEPEND="2:2.5"
PYTHON_USE_WITH="sqlite"

inherit eutils multilib python


MY_P="$P"
MY_P="${MY_P/sab/SAB}"
MY_P="${MY_P/_beta/Beta}"
MY_P="${MY_P/_rc/RC}"

DESCRIPTION="Binary Newsgrabber written in Python, server-oriented using a web-interface.The active successor of the abandoned SABnzbd project."
HOMEPAGE="http://www.sabnzbd.org/"
SRC_URI="mirror://sourceforge/sabnzbdplus/${MY_P}-src.tar.gz"

HOMEDIR="${ROOT}var/lib/${PN}"
DHOMEDIR="/var/lib/${PN}"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+rar unzip rss +yenc ssl"

RDEPEND="
		>=dev-python/celementtree-1.0.5
		>=dev-python/cheetah-2.0.1
		>=app-arch/par2cmdline-0.4
		rar? ( >=app-arch/unrar-3.9.0 )
		unzip? ( >=app-arch/unzip-5.5.2 )
		yenc? ( >=dev-python/yenc-0.3 )
		ssl? ( >=dev-python/pyopenssl-0.7
			dev-libs/openssl )"
DEPEND="${RDEPEND}
		app-text/dos2unix"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	#Control PYTHON_USE_WITH
	python_set_active_version 2
	python_pkg_setup

	#Create sabnzbd group
	enewgroup "${PN}"
	# Create sabnzbd user, put in sabnzbd group
	enewuser "${PN}" -1 -1 "${HOMEDIR}" "${PN}"
}

src_unpack() {
	unpack ${A}
}

src_install() {

	cp "${FILESDIR}/${PN}.ini" "${S}" || die "copying sample ${PN}.ini"

	dodoc CHANGELOG.txt ISSUES.txt INSTALL.txt README.txt Sample-PostProc.sh Sample-PostProc.cmd

	insopts -m0660 -o root -g ${PN}
	newconfd "${FILESDIR}/${PN}.conf" "${PN}"

	newinitd "${FILESDIR}/${PN}.init" "${PN}"

	#SABnzbd >=0.6.0 write temp files when editing config from the web GUI, so directory needs to be writable by the SABnzbd process
	diropts -m0770 -o root -g ${PN}
	dodir /etc/${PN}

	insinto /etc/${PN}/
	insopts -m0660 -o root -g ${PN}
	doins "${PN}.ini" || die "newins ${PN}.ini"

	#Create all default dirs & mark with .keep so portage will not remove them
	keepdir ${DHOMEDIR}
	for i in admin cache complete download dirscan incomplete nzb_backup scripts; do
		keepdir ${DHOMEDIR}/${i}
	done

	#Create & assign ownership of SABnzbd default directories
	fowners -R root:${PN} ${DHOMEDIR}
	fperms -R 770 ${DHOMEDIR}

	#Create & assign ownership of SABnzbd log directory
	keepdir /var/log/${PN}
	fowners -R root:${PN} /var/log/${PN}
	fperms -R 770 /var/log/${PN}

	#Create & assign ownership of SABnzbd PID directory
	keepdir /var/run/${PN}
	fowners -R root:${PN} /var/run/${PN}
	fperms -R 770 /var/run/${PN}

	#Add themes & code into /usr/share
	dodir /usr/share/${PN}
	insinto /usr/share/${PN}
	for i in cherrypy gntp interfaces sabnzbd email locale po tools util;do
		doins -r $i || die "installing $i directory"
	done

	doins SABnzbd.py || die "installing SABnzbd.py"

	#Adjust permissions in python source directory for root:sabnzbd
	fowners -R root:${PN} /usr/share/${PN}
	fperms -R 770 /usr/share/${PN}
}

pkg_postinst() {
	python_mod_optimize /usr/share/${PN}

	einfo "SABnzbd has been installed with default directories in ${HOMEDIR}"
	einfo "Email templates can be found in: ${ROOT}usr/share/${PN}/email"
	einfo ""
	einfo "By default, SABnzbd runs as the unprivileged user \"sabnzbd\""
	einfo "on port 8080 with no API key."
	einfo ""
	einfo "Be sure to that the \"sabnzbd\" user has the appropriate"
	einfo "permissions to read/write to any non-default directories"
	einfo "if changed in ${PN}.ini"
	einfo ""
	einfo "Configuration files are accessible only to users in the \"sabnzbd\" group"
	einfo "Run 'gpasswd -a <user> sabnzbd' to add a  user to the sabnzbd group"
	einfo "so it can edit the appropriate configuration files"
	einfo ""
	ewarn "Please configure /etc/conf.d/${PN} before starting!"
        ewarn "If you use SSL connection for SABnzbd WebUi, you have to change SAB_PORT to 9090 in /etc/conf.d/${PN}"
	ewarn ""
	ewarn "Start with ${ROOT}etc/init.d/${PN} start"
	ewarn "Visit http://<host ip>:8080 to configure SABnzbd"
	ewarn "Default web username/password : sabnzbd/secret"
}
