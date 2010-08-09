#!/bin/sh

# defaults.sh - handle default values
# Copyright (C) 2006-2010 Daniel Baumann <daniel@debian.org>
#
# live-helper comes with ABSOLUTELY NO WARRANTY; for details see COPYING.
# This is free software, and you are welcome to redistribute it
# under certain conditions; see COPYING for details.

Set_defaults ()
{
	## config/common

	LH_BASE="${LH_BASE:-/usr/share/live-helper}"

	# Setting mode
	if [ -z "${LH_MODE}" ]
	then
		LH_MODE="debian"
	fi

	# Setting distribution name
	if [ -z "${LH_DISTRIBUTION}" ]
	then
		case "${LH_MODE}" in
			debian|debian-release)
				LH_DISTRIBUTION="lenny"
				;;
		esac
	fi

	# Setting package manager
	LH_APT="${LH_APT:-apt}"

	# Setting apt ftp proxy
	if [ -z "${LH_APT_FTP_PROXY}" ] && [ -n "${ftp_proxy}" ]
	then
		LH_APT_FTP_PROXY="${ftp_proxy}"
	else
		if [ -n "${LH_APT_FTP_PROXY}" ] && [ "${LH_APT_FTP_PROXY}" != "${ftp_proxy}" ]
		then
			ftp_proxy="${LH_APT_FTP_PROXY}"
		fi
	fi

	# Setting apt http proxy
	if [ -z "${LH_APT_HTTP_PROXY}" ] && [ -n "${http_proxy}" ]
	then
		LH_APT_HTTP_PROXY="${http_proxy}"
	else
		if [ -n "${LH_APT_HTTP_PROXY}" ] && [ "${LH_APT_HTT_PROXY}" != "${http_proxy}" ]
		then
			http_proxy="${LH_APT_HTTP_PROXY}"
		fi
	fi

	# Setting apt pdiffs
	LH_APT_PDIFFS="${LH_APT_PDIFFS:-true}"

	# Setting apt pipeline
	# LH_APT_PIPELINE

	APT_OPTIONS="${APT_OPTIONS:---yes}"
	APTITUDE_OPTIONS="${APTITUDE_OPTIONS:---assume-yes}"

	GZIP_OPTIONS="${GZIP_OPTIONS:---best}"

	if gzip --help | grep -qs "\-\-rsyncable"
	then
		GZIP_OPTIONS="$(echo ${GZIP_OPTIONS} | sed -e 's|--rsyncable||') --rsyncable"
	fi

	# Setting apt recommends
	case "${LH_MODE}" in
		debian)
			LH_APT_RECOMMENDS="${LH_APT_RECOMMENDS:-true}"
			;;
	esac

	# Setting apt secure
	LH_APT_SECURE="${LH_APT_SECURE:-true}"

	# Setting bootstrap program
	if [ -z "${LH_BOOTSTRAP}" ] || ( [ ! -x "$(which ${LH_BOOTSTRAP} 2>/dev/null)" ] && [ "${LH_BOOTSTRAP}" != "copy" ] )
	then
		if [ -x "/usr/sbin/debootstrap" ]
		then
			LH_BOOTSTRAP="debootstrap"
		elif [ -x "/usr/bin/cdebootstrap" ]
		then
			LH_BOOTSTRAP="cdebootstrap"
		else
			Echo_error "Cannot find /usr/sbin/debootstrap or /usr/bin/cdebootstrap. Please install debootstrap or cdebootstrap, or specify an alternative bootstrapping utility."
			exit 1
		fi
	fi

	# Setting cache option
	LH_CACHE="${LH_CACHE:-true}"
	LH_CACHE_INDICES="${LH_CACHE_INDICES:-false}"
	LH_CACHE_PACKAGES="${LH_CACHE_PACKAGES:-true}"
	LH_CACHE_STAGES="${LH_CACHE_STAGES:-bootstrap}"

	# Setting debconf frontend
	LH_DEBCONF_FRONTEND="${LH_DEBCONF_FRONTEND:-noninteractive}"
	LH_DEBCONF_NOWARNINGS="${LH_DEBCONF_NOWARNINGS:-yes}"
	LH_DEBCONF_PRIORITY="${LH_DEBCONF_PRIORITY:-critical}"

	case "${LH_DEBCONF_NOWARNINGS}" in
		true)
			LH_DEBCONF_NOWARNINGS="yes"
			;;

		false)
			LH_DEBCONF_NOWARNINGS="no"
			;;
	esac

	# Setting initramfs hook
	if [ -z "${LH_INITRAMFS}" ]
	then
		LH_INITRAMFS="auto"
	else
		if [ "${LH_INITRAMFS}" = "auto" ]
		then
			case "${LH_MODE}" in
				ubuntu)
					LH_INITRAMFS="casper"
					;;

				*)
					LH_INITRAMFS="live-initramfs"
					;;
			esac
		fi
	fi

	# Setting fdisk
	if [ -z "${LH_FDISK}" ] || [ ! -x "${LH_FDISK}" ]
	then
		# Workaround for gnu-fdisk divertion
		# (gnu-fdisk is buggy, #445304).
		if [ -x /sbin/fdisk.distrib ]
		then
			LH_FDISK="fdisk.distrib"
		elif [ -x /sbin/fdisk ]
		then
			LH_FDISK="fdisk"
		else
			Echo_error "Can't process file /sbin/fdisk"
		fi
	fi

	# Setting losetup
	if [ -z "${LH_LOSETUP}" ] || [ "${LH_LOSETUP}" != "/sbin/losetup.orig" ]
	then
		# Workaround for loop-aes-utils divertion
		# (loop-aes-utils' losetup lacks features).
		if [ -x /sbin/losetup.orig ]
		then
			LH_LOSETUP="losetup.orig"
		elif [ -x /sbin/losetup ]
		then
			LH_LOSETUP="losetup"
		else
			Echo_error "Can't process file /sbin/losetup"
		fi
	fi

	if [ "$(id -u)" = "0" ]
	then
		# If we are root, disable root command
		LH_ROOT_COMMAND=""
	else
		if [ -x /usr/bin/sudo ]
		then
			LH_ROOT_COMMAND="sudo"		
		fi
	fi

	# Setting tasksel
	LH_TASKSEL="${LH_TASKSEL:-tasksel}"

	# Setting root directory
	if [ -z "${LH_ROOT}" ]
	then
		case "${LH_MODE}" in
			debian|debian-release)
				LH_ROOT="debian-live"
				;;

			emdebian)
				LH_ROOT="emdebian-live"
				;;

			ubuntu)
				LH_ROOT="ubuntu-live"
				;;
		esac
	fi

	# Setting includes
	if [ -z "${LH_INCLUDES}" ]
	then
		LH_INCLUDES="${LH_BASE}/includes"
	fi

	# Setting templates
	if [ -z "${LH_TEMPLATES}" ]
	then
		LH_TEMPLATES="${LH_BASE}/templates"
	fi

	# Setting live helper options
	_BREAKPOINTS="${_BREAKPOINTS:-false}"
	_COLOR="${_COLOR:-false}"
	_DEBUG="${_DEBUG:-false}"
	_FORCE="${_FORCE:-false}"
	_QUIET="${_QUIET:-false}"
	_VERBOSE="${_VERBOSE:-false}"

	## config/bootstrap

	# Setting architecture value
	if [ -z "${LH_ARCHITECTURE}" ]
	then
		if [ -x "/usr/bin/dpkg" ]
		then
			LH_ARCHITECTURE="$(dpkg --print-architecture)"
		else
			case "$(uname -m)" in
				sparc|powerpc)
					LH_ARCHITECTURE="$(uname -m)"
					;;
				x86_64)
					LH_ARCHITECTURE="amd64"
					;;
				*)
					Echo_warning "Can't determine architecture, assuming i386"
					LH_ARCHITECTURE="i386"
					;;
			esac
		fi
	fi

	# Include packages on base
	# LH_BOOTSTRAP_INCLUDE

	# Exclude packages on base
	# LH_BOOTSTRAP_EXCLUDE

	# Setting distribution configuration value
	# LH_BOOTSTRAP_CONFIG

	# Setting flavour value
	case "${LH_BOOTSTRAP}" in
		cdebootstrap)
			LH_BOOTSTRAP_FLAVOUR="${LH_BOOTSTRAP_FLAVOUR:-standard}"
			;;
		debootstrap)
                        LH_BOOTSTRAP_FLAVOUR="${LH_BOOTSTRAP_FLAVOUR:-minimal}"
                        ;;
	esac

	# Setting bootstrap keyring
	# LH_BOOTSTRAP_KEYRING

	# Setting mirror to fetch packages from
	if [ -z "${LH_MIRROR_BOOTSTRAP}" ]
	then
		case "${LH_MODE}" in
			debian)
				LH_MIRROR_BOOTSTRAP="http://universo.canaima.softwarelibre.gob.ve/"
				;;
		esac
	fi

	LH_MIRROR_CHROOT="${LH_MIRROR_CHROOT:-${LH_MIRROR_BOOTSTRAP}}"

	# Setting security mirror to fetch packages from
	if [ -z "${LH_MIRROR_CHROOT_SECURITY}" ]
	then
		case "${LH_MODE}" in
			debian)
				LH_MIRROR_CHROOT_SECURITY="none"
				;;
		esac
	fi

	# Setting volatile mirror to fetch packages from
	if [ -z "${LH_MIRROR_CHROOT_VOLATILE}" ]
	then
		case "${LH_MODE}" in
			debian)
				case "${LH_DISTRIBUTION}" in
					lenny)
						LH_MIRROR_CHROOT_VOLATILE="none"
						;;
				esac
				;;
		esac

		LH_MIRROR_CHROOT_VOLATILE="${LH_MIRROR_CHROOT_VOLATILE:-none}"
	fi

	# Setting mirror which ends up in the image
	if [ -z "${LH_MIRROR_BINARY}" ]
	then
		case "${LH_MODE}" in
			debian)
				LH_MIRROR_BINARY="http://universo.canaima.softwarelibre.gob.ve/"
				;;
		esac
	fi

	# Setting security mirror which ends up in the image
	if [ -z "${LH_MIRROR_BINARY_SECURITY}" ]
	then
		case "${LH_MODE}" in
			debian)
				LH_MIRROR_BINARY_SECURITY="http://universo.canaima.softwarelibre.gob.ve/"
				;;
		esac
	fi

	# Setting volatile mirror which ends up in the image
	if [ -z "${LH_MIRROR_BINARY_VOLATILE}" ]
	then
		case "${LH_MODE}" in
			debian)
				LH_MIRROR_BINARY_VOLATILE="none"
				;;
		esac

		LH_MIRROR_BINARY_VOLATILE="${LH_MIRROR_BINARY_VOLATILE:-none}"
	fi

	LH_MIRROR_DEBIAN_INSTALLER="${LH_MIRROR_DEBIAN_INSTALLER:-${LH_MIRROR_BOOTSTRAP}}"

	# Setting archive areas value
	if [ -z "${LH_ARCHIVE_AREAS}" ]
	then
		case "${LH_MODE}" in
			debian)
				LH_ARCHIVE_AREAS="main contrib non-free"
				;;
		esac
	fi

	## config/chroot

	# Setting chroot filesystem
	LH_CHROOT_FILESYSTEM="${LH_CHROOT_FILESYSTEM:-squashfs}"

	# Setting virtual root size
	LH_VIRTUAL_ROOT_SIZE="${LH_VIRTUAL_ROOT_SIZE:-10000}"

	# Setting whether to expose root filesystem as read only
	LH_EXPOSED_ROOT="${LH_EXPOSED_ROOT:-false}"

	# Setting union filesystem
	LH_UNION_FILESYSTEM="${LH_UNION_FILESYSTEM:-aufs}"

	# LH_HOOKS

	# Setting interactive shell/X11/Xnest
	LH_INTERACTIVE="${LH_INTERACTIVE:-false}"

	# Setting keyring packages
	case "${LH_MODE}" in
		debian)
			LH_KEYRING_PACKAGES="${LH_KEYRING_PACKAGES:-debian-archive-keyring}"
			;;
	esac

	# Setting language string
	LH_LANGUAGE="${LH_LANGUAGE:-es}"

	# Setting linux flavour string
	if [ -z "${LH_LINUX_FLAVOURS}" ]
	then
		case "${LH_ARCHITECTURE}" in
			amd64)
				case "${LH_MODE}" in
					debian)
						LH_LINUX_FLAVOURS="amd64"
						;;
				esac
				;;
			i386)
				case "${LH_MODE}" in
					debian)
						LH_LINUX_FLAVOURS="686"
						;;
				esac
				;;
		esac
	fi

	# Set linux packages
	if [ -z "${LH_LINUX_PACKAGES}" ]
	then
		case "${LH_MODE}" in
			debian|debian-release|embedian)
				case "${LH_DISTRIBUTION}" in
					lenny)
						LH_LINUX_PACKAGES="linux-image-2.6 \${LH_UNION_FILESYSTEM}-modules-2.6"
						;;

					*)
						LH_LINUX_PACKAGES="linux-image-2.6"
						;;
				esac

				if [ "${LH_CHROOT_FILESYSTEM}" = "squashfs" ]
				then
					case "${LH_DISTRIBUTION}" in
						lenny)
							LH_LINUX_PACKAGES="${LH_LINUX_PACKAGES} squashfs-modules-2.6"
							;;
					esac
				fi

				case "${LH_ENCRYPTION}" in
					""|false)

						;;

					*)
						LH_LINUX_PACKAGES="${LH_LINUX_PACKAGES} loop-aes-modules-2.6"
						;;
				esac
				;;

			ubuntu)
				LH_LINUX_PACKAGES="linux"
				;;
		esac
	fi

	# Setting packages string
	case "${LH_MODE}" in
		ubuntu)
			LH_PACKAGES="${LH_PACKAGES:-ubuntu-minimal}"
			;;

		*)
			LH_PACKAGES_LISTS="${LH_PACKAGES_LISTS:-standard}"
			;;
	esac

	case "${LH_ENCRYPTION}" in
		""|false)

			;;

		*)
			if ! In_list loop-aes-utils "${LH_PACKAGES}"
			then
				LH_PACKAGES="${LH_PACKAGES} loop-aes-utils"
			fi
			;;
	esac

	# Setting tasks string
	for LIST in ${LH_PACKAGES_LISTS}
	do
		case "${LIST}" in
			stripped|minimal)
				LH_APT="apt-get"
				;;

			gnome-desktop)
				LH_PACKAGES_LISTS="$(echo ${LH_PACKAGES_LISTS} | sed -e 's|gnome-desktop||') standard-x11"
				case "${LH_DISTRIBUTION}" in
					lenny)
						LH_TASKS="$(echo ${LH_TASKS} | sed -e 's|standard||' -e 's|gnome-desktop||' -e 's|desktop||') standard gnome-desktop desktop"
						;;

					*)
						LH_TASKS="$(echo ${LH_TASKS} | sed -e 's|standard||' -e 's|gnome-desktop||' -e 's|desktop||' -e 's|laptop||') standard gnome-desktop desktop laptop"
						;;
				esac
				;;

			kde-desktop)
				LH_PACKAGES_LISTS="$(echo ${LH_PACKAGES_LISTS} | sed -e 's|kde-desktop||') standard-x11"

				case "${LH_DISTRIBUTION}" in
					lenny)
						LH_TASKS="$(echo ${LH_TASKS} | sed -e 's|standard||' -e 's|kde-desktop||' -e 's|desktop||') standard kde-desktop desktop"
						;;

					*)
						LH_TASKS="$(echo ${LH_TASKS} | sed -e 's|standard||' -e 's|kde-desktop||' -e 's|desktop||' -e 's|laptop||') standard kde-desktop desktop laptop"
				esac
				;;

			lxde-desktop)
				LH_PACKAGES_LISTS="$(echo ${LH_PACKAGES_LISTS} | sed -e 's|lxde-desktop||') standard-x11"

				case "${LH_DISTRIBUTION}" in
					lenny)
						LH_TASKS="$(echo ${LH_TASKS} | sed -e 's|standard||' -e 's|lxde-desktop||' -e 's|desktop||') standard lxde-desktop desktop"
						;;

					*)
						LH_TASKS="$(echo ${LH_TASKS} | sed -e 's|standard||' -e 's|lxde-desktop||' -e 's|desktop||' -e 's|laptop||') standard lxde-desktop desktop laptop"
						;;
				esac
				;;

			xfce-desktop)
				LH_PACKAGES_LISTS="$(echo ${LH_PACKAGES_LISTS} | sed -e 's|xfce-desktop||') standard-x11"

				case "${LH_DISTRIBUTION}" in
					lenny)
						LH_TASKS="$(echo ${LH_TASKS} | sed -e 's|standard||' -e 's|xfce-desktop||' -e 's|desktop||') standard xfce-desktop desktop"
						;;

					*)
						LH_TASKS="$(echo ${LH_TASKS} | sed -e 's|standard||' -e 's|xfce-desktop||' -e 's|desktop||' -e 's|laptop||') standard xfce-desktop desktop laptop"
						;;
				esac
				;;
		esac
	done

	LH_PACKAGES_LISTS="$(echo ${LH_PACKAGES_LISTS} | sed -e 's|  ||g')"
	LH_TASKS="$(echo ${LH_TASKS} | sed -e 's|  ||g')"

	# Setting security updates option
	if [ "${LH_MIRROR_CHROOT_SECURITY}" = "none" ] || [ "${LH_MIRROR_BINARY_SECURITY}" = "none" ]
	then
		LH_SECURITY="false"
	fi

	LH_SECURITY="${LH_SECURITY:-true}"

	# Setting volatile updates option
	if [ "${LH_MIRROR_CHROOT_VOLATILE}" = "none" ] || [ "${LH_MIRROR_BINARY_VOLATILE}" = "none" ]
	then
		LH_VOLATILE="false"
	fi

	LH_VOLATILE="${LH_VOLATILE:-true}"

	# Setting symlink convertion option
	LH_SYMLINKS="${LH_SYMLINKS:-false}"

	# Setting sysvinit option
	LH_SYSVINIT="${LH_SYSVINIT:-false}"

	## config/binary

	# Setting image filesystem
	case "${LH_ARCHITECTURE}" in
		sparc)
			LH_BINARY_FILESYSTEM="${LH_BINARY_FILESYSTEM:-ext2}"
			;;

		*)
			LH_BINARY_FILESYSTEM="${LH_BINARY_FILESYSTEM:-fat16}"
			;;
	esac

	# Setting image type
	case "${LH_DISTRIBUTION}" in
		squeeze|sid)
			case "${LH_ARCHITECTURE}" in
				amd64|i386)
					LH_BINARY_IMAGES="${LH_BINARY_IMAGES:-iso-hybrid}"
					;;

				*)
					LH_BINARY_IMAGES="${LH_BINARY_IMAGES:-iso}"
					;;
			esac
			;;

		*)
			LH_BINARY_IMAGES="${LH_BINARY_IMAGES:-iso}"
			;;
	esac

	# Setting apt indices
	if echo ${LH_PACKAGES_LISTS} | grep -qs -E "(stripped|minimal)\b"
	then
		LH_BINARY_INDICES="${LH_BINARY_INDICES:-none}"
	else
		LH_BINARY_INDICES="${LH_BINARY_INDICES:-true}"
	fi

	# Setting bootloader
	if [ -z "${LH_BOOTLOADER}" ]
	then
		case "${LH_ARCHITECTURE}" in
			amd64|i386)
				LH_BOOTLOADER="syslinux"
				;;

			powerpc)
				LH_BOOTLOADER="yaboot"
				;;

			sparc)
				LH_BOOTLOADER="silo"
				;;
		esac
	fi

	# Setting checksums
	LH_CHECKSUMS="${LH_CHECKSUMS:-md5}"

	# Setting chroot option
	LH_BUILD_WITH_CHROOT="${LH_BUILD_WITH_CHROOT:-true}"

	# Setting debian-installer option
	LH_DEBIAN_INSTALLER="${LH_DEBIAN_INSTALLER:-false}"

	# Setting debian-installer distribution
	LH_DEBIAN_INSTALLER_DISTRIBUTION="${LH_DEBIAN_INSTALLER_DISTRIBUTION:-${LH_DISTRIBUTION}}"

	# Setting debian-installer-gui
	case "${LH_MODE}" in
		debian)
			case "${LH_DISTRIBUTION}" in
				squeeze|sid)
					LH_DEBIAN_INSTALLER_GUI="${LH_DEBIAN_INSTALLER_GUI:-false}"
					;;

				*)
					LH_DEBIAN_INSTALLER_GUI="${LH_DEBIAN_INSTALLER_GUI:-true}"
					;;
			esac
			;;

		ubuntu)
			case "${LH_DEBIAN_INSTALLER_DISTRIBUTION}" in
				karmic)
					# Not available for Karmic currently.
					LH_DEBIAN_INSTALLER_GUI="${LH_DEBIAN_INSTALLER_GUI:-false}"
					;;

				*)
					LH_DEBIAN_INSTALLER_GUI="${LH_DEBIAN_INSTALLER_GUI:-true}"
					;;
			esac
			;;

		*)
			LH_DEBIAN_INSTALLER_GUI="${LH_DEBIAN_INSTALLER_GUI:-false}"
			;;
	esac

	# Setting debian-installer preseed filename
	if [ -z "${LH_DEBIAN_INSTALLER_PRESEEDFILE}" ]
	then
		if Find_files config/binary_debian-installer/preseed.cfg
		then
			LH_DEBIAN_INSTALLER_PRESEEDFILE="/preseed.cfg"
		fi

		if Find_files config/binary_debian-installer/*.cfg && [ ! -e config/binary_debian-installer/preseed.cfg ]
		then
			Echo_warning "You have placed some preseeding files into config/binary_debian-installer but you didn't specify the default preseeding file through LH_DEBIAN_INSTALLER_PRESEEDFILE. This means that debian-installer will not take up a preseeding file by default."
		fi
	fi

	# Setting boot parameters
	# LH_BOOTAPPEND_LIVE
	if [ -n "${LH_DEBIAN_INSTALLER_PRESEEDFILE}" ]
	then
		case "${LH_BINARY_IMAGES}" in
			iso*)
				_LH_BOOTAPPEND_PRESEED="file=/cdrom/install/${LH_DEBIAN_INSTALLER_PRESEEDFILE}"
				;;

			usb*)
				if [ "${LH_MODE}" = "ubuntu" ] || [ "${LH_DEBIAN_INSTALLER}" = "live" ]
				then
					_LH_BOOTAPPEND_PRESEED="file=/cdrom/install/${LH_DEBIAN_INSTALLER_PRESEEDFILE}"
				else
					_LH_BOOTAPPEND_PRESEED="file=/hd-media/install/${LH_DEBIAN_INSTALLER_PRESEEDFILE}"
				fi
				;;

			net)
				case "${LH_DEBIAN_INSTALLER_PRESEEDFILE}" in
					*://*)
						_LH_BOOTAPPEND_PRESEED="file=${LH_DEBIAN_INSTALLER_PRESEEDFILE}"
						;;

					*)
						_LH_BOOTAPPEND_PRESEED="file=/${LH_DEBIAN_INSTALLER_PRESEEDFILE}"
						;;
				esac
				;;
		esac
	fi

	case "${LH_BINARY_IMAGES}" in
		iso-hybrid|usb*)
			# Try USB block devices for install media
			if ! echo "${LH_BOOTAPPEND_INSTALL}" | grep -q try-usb
			then
				LH_BOOTAPPEND_INSTALL="cdrom-detect/try-usb=true ${LH_BOOTAPPEND_INSTALL}"
			fi
			;;
	esac

	if [ -n ${_LH_BOOTAPPEND_PRESEED} ]
	then
		LH_BOOTAPPEND_INSTALL="${LH_BOOTAPPEND_INSTALL} ${_LH_BOOTAPPEND_PRESEED}"
	fi

	LH_BOOTAPPEND_INSTALL="$(echo ${LH_BOOTAPPEND_INSTALL} | sed -e 's/[ \t]*$//')"

	# Setting encryption
	LH_ENCRYPTION="${LH_ENCRYPTION:-false}"

	# Setting grub splash
	# LH_GRUB_SPLASH

	# Setting hostname
	if [ -z "${LH_HOSTNAME}" ]
	then
		case "${LH_MODE}" in
			embedian)
				LH_HOSTNAME="embedian"
				;;

			ubuntu)
				LH_HOSTNAME="ubuntu"
				;;

			*)
				LH_HOSTNAME="debian"
				;;
		esac
	fi

	# Setting iso author
	if [ -z "${LH_ISO_APPLICATION}" ]
	then
		case "${LH_MODE}" in
			debian|debian-release)
				LH_ISO_APPLICATION="Debian Live"
				;;

			emdebian)
				LH_ISO_APPLICATION="Emdebian Live"
				;;

			ubuntu)
				LH_ISO_APPLICATION="Ubuntu Live"
				;;
		esac
	fi

	# Set iso preparer
	LH_ISO_PREPARER="${LH_ISO_PREPARER:-live-helper \$VERSION; http://packages.qa.debian.org/live-helper}"

	# Set iso publisher
	LH_ISO_PUBLISHER="${LH_ISO_PUBLISHER:-Debian Live project; http://debian-live.alioth.debian.org/; debian-live@lists.debian.org}"

	# Setting iso volume
	if [ -z "${LH_ISO_VOLUME}" ]
	then
		case "${LH_MODE}" in
			debian)
				LH_ISO_VOLUME="Debian ${LH_DISTRIBUTION} \$(date +%Y%m%d-%H:%M)"
				;;

			debian-release)
				eval VERSION="$`echo RELEASE_${LH_DISTRIBUTION}`"
				LH_ISO_VOLUME="Debian ${VERSION} ${LH_ARCHITECTURE} live"
				;;

			emdebian)
				LH_ISO_VOLUME="Emdebian ${LH_DISTRIBUTION} \$(date +%Y%m%d-%H:%M)"
				;;

			ubuntu)
				LH_ISO_VOLUME="Ubuntu ${LH_DISTRIBUTION} \$(date +%Y%m%d-%H:%M)"
				;;
		esac
	fi

	# Setting memtest option
	LH_MEMTEST="${LH_MEMTEST:-memtest86+}"

	# Setting win32-loader option
	if [ "${LH_MODE}" != "ubuntu" ]
	then
		case "${LH_ARCHITECTURE}" in
			amd64|i386)
				if [ "${LH_DEBIAN_INSTALLER}" != "false" ]
				then
					LH_WIN32_LOADER="${LH_WIN32_LOADER:-true}"
				else
					LH_WIN32_LOADER="${LH_WIN32_LOADER:-false}"
				fi
				;;

			*)
				LH_WIN32_LOADER="${LH_WIN32_LOADER:-false}"
				;;
		esac
	fi

	# Setting netboot filesystem
	LH_NET_ROOT_FILESYSTEM="${LH_NET_ROOT_FILESYSTEM:-nfs}"

	# Setting netboot server path
	if [ -z "${LH_NET_ROOT_PATH}" ]
	then
		case "${LH_MODE}" in
			debian|debian-release)
				LH_NET_ROOT_PATH="/srv/debian-live"
				;;

			emdebian)
				LH_NET_ROOT_PATH="/srv/emdebian-live"
				;;

			ubuntu)
				LH_NET_ROOT_PATH="/srv/ubuntu-live"
				;;
		esac
	fi

	# Setting netboot server address
	LH_NET_ROOT_SERVER="${LH_NET_ROOT_SERVER:-192.168.1.1}"

	# Setting net cow filesystem
	LH_NET_COW_FILESYSTEM="${LH_NET_COW_FILESYSTEM:-nfs}"

	# Setting net tarball
	LH_NET_TARBALL="${LH_NET_TARBALL:-gzip}"

	# Setting syslinux configuration file
	# LH_SYSLINUX_CFG

	# Setting syslinux splash
	# LH_SYSLINUX_SPLASH

	LH_SYSLINUX_TIMEOUT="${LH_SYSLINUX_TIMEOUT:-0}"

	# Setting syslinux menu
	LH_SYSLINUX_MENU="${LH_SYSLINUX_MENU:-true}"

	# Setting syslinux menu live entries
	case "${LH_MODE}" in
		debian|debian-release)
			LH_SYSLINUX_MENU_LIVE_ENTRY="${LH_SYSLINUX_MENU_LIVE_ENTRY:-Live}"
			LH_SYSLINUX_MENU_LIVE_ENTRY_FAILSAFE="${LH_SYSLINUX_MENU_LIVE_ENTRY_FAILSAFE:-${LH_SYSLINUX_MENU_LIVE_ENTRY} (failsafe)}"
			;;

		*)
			LH_SYSLINUX_MENU_LIVE_ENTRY="${LH_SYSLINUX_MENU_LIVE_ENTRY:-Start ${LH_ISO_APPLICATION}}"
			LH_SYSLINUX_MENU_LIVE_ENTRY_FAILSAFE="${LH_SYSLINUX_MENU_LIVE_ENTRY_FAILSAFE:-${LH_SYSLINUX_MENU_LIVE_ENTRY} (failsafe)}"
			;;
	esac

	# Settings memtest menu entry
	LH_SYSLINUX_MENU_MEMTEST_ENTRY="${LH_SYSLINUX_MENU_MEMTEST_ENTRY:-Memory test}"

	# Setting username
	case "${LH_MODE}" in
		ubuntu)
			LH_USERNAME="${LH_USERNAME:-ubuntu}"
			;;

		*)
			LH_USERNAME="${LH_USERNAME:-user}"
			;;
	esac

	## config/source

	# Setting source option
	LH_SOURCE="${LH_SOURCE:-false}"

	# Setting image type
	LH_SOURCE_IMAGES="${LH_SOURCE_IMAGES:-tar}"

	# Setting fakeroot/fakechroot
	LH_USE_FAKEROOT="${LH_USE_FAKEROOT:-false}"
}

Check_defaults ()
{
	if [ "${LH_CONFIG_VERSION}" ]
	then
		# We're only checking when we're actually running the checks
		# that's why the check for emptyness of the version;
		# however, as live-helper always declares LH_CONFIG_VERSION
		# internally, this is safe assumption (no cases where it's unset,
		# except when bootstrapping the functions/defaults etc.).
		CURRENT_CONFIG_VERSION="$(echo ${LH_CONFIG_VERSION} | awk -F. '{ print $1 }')"

		if [ ${CURRENT_CONFIG_VERSION} -ge 3 ]
		then
			Echo_error "This config tree is too new for this version of live-helper (${VERSION})."
			Echo_error "Aborting build, please get a new version of live-helper."

			exit 1
		elif [ ${CURRENT_CONFIG_VERSION} -eq 1 ]
		then
			Echo_error "This config tree is too old for this version of live-heloer (${VERSION})."
			Echo_error "Aborting build, please repopulate the config tree."
			exit 1
		elif [ ${CURRENT_CONFIG_VERSION} -lt 1 ]
		then
			Echo_warning "This config tree does not specify a format version or has an unknown version number."
			Echo_warning "Continuing build, but it could lead to errors or different results. Please repopulate the config tree."
		fi
	fi

	if echo ${LH_PACKAGES_LISTS} | grep -qs -E "(stripped|minimal)\b"
	then
		# aptitude + stripped|minimal
		if [ "${LH_APT}" = "aptitude" ]
		then
			Echo_warning "You selected LH_PACKAGES_LISTS='%s' and LH_APT='aptitude'" "${LH_PACKAGES_LIST}. This configuration is potentially unsafe, as aptitude is not used in the stripped/minimal package lists."
		fi
	fi

	if [ "${LH_DEBIAN_INSTALLER}" != "false" ]
	then
		# d-i true, no caching
		if ! echo ${LH_CACHE_STAGES} | grep -qs "bootstrap\b" || [ "${LH_CACHE}" != "true" ] || [ "${LH_CACHE_PACKAGES}" != "true" ]
		then
			Echo_warning "You have selected values of LH_CACHE, LH_CACHE_PACKAGES, LH_CACHE_STAGES and LH_DEBIAN_INSTALLER which will result in 'bootstrap' packages not being cached. This configuration is potentially unsafe as the bootstrap packages are re-used when integrating the Debian Installer."
		fi
	fi

	if [ "${LH_BOOTLOADER}" = "syslinux" ]
	then
		# syslinux + fat
		case "${LH_BINARY_FILESYSTEM}" in
			fat*)
				;;
			*)
				Echo_warning "You have selected values of LH_BOOTLOADER and LH_BINARY_FILESYSTEM which are incompatible - syslinux only supports FAT filesystems."
				;;
		esac
	fi

	case "${LH_BINARY_IMAGES}" in
		usb*)
			# grub or yaboot + usb
			case "${LH_BOOTLOADER}" in
				grub|yaboot)
					Echo_error "You have selected a combination of bootloader and image type that is currently not supported by live-helper. Please use either another bootloader or a different image type."
					exit 1
					;;
			esac
			;;
	esac

	if [ "$(echo ${LH_ISO_APPLICATION} | wc -c)" -gt 128 ]
	then
		Echo_warning "You have specified a value of LH_ISO_APPLICATION that is too long; the maximum length is 128 characters."
	fi

	if [ "$(echo ${LH_ISO_PREPARER} | wc -c)" -gt  128 ]
	then
		Echo_warning "You have specified a value of LH_ISO_PREPARER that is too long; the maximum length is 128 characters."
	fi

	if [ "$(echo ${LH_ISO_PUBLISHER} | wc -c)" -gt 128 ]
	then
		Echo_warning "You have specified a value of LH_ISO_PUBLISHER that is too long; the maximum length is 128 characters."
	fi

	if [ "$(eval "echo ${LH_ISO_VOLUME}" | wc -c)" -gt 32 ]
	then
		Echo_warning "You have specified a value of LH_ISO_VOLUME that is too long; the maximum length is 32 characters."
	fi

	if echo ${LH_PACKAGES_LISTS} | grep -qs -E "(stripped|minimal)\b"
	then
		if [ "${LH_BINARY_INDICES}" = "true" ]
		then
			Echo_warning "You have selected hook to minimise image size but you are still including package indices with your value of LH_BINARY_INDICES."
		fi
	fi

}