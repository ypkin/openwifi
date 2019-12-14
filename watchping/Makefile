# 
# Copyright (C) 2012 Guido Iribarren
#
# This is free software, licensed under the GNU General Public License v3.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=watchping
PKG_VERSION:=1.1
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/watchping
  SUBMENU:=Wifimedia
  SECTION:=dev
  CATEGORY:=Advance
  TITLE:=Ping a host and run customizable actions (hooks) on timeout/recovery.
  URL:=http://wifimedia.vn
  MENU:=1
  PKGARCH:=all
  MAINTAINER:=DungTD <dungtd8x@gmail.com>

endef

define Package/watchping/description
  Checks reachability of given host(s) through particular interface(s) (e.g. 8.8.8.8 on WAN). 
  Action hooks are run from /etc/watchping/*.d/
  Configuration is done in /etc/config/system.
endef

define Package/watchping/conffiles
/etc/config/system
endef

define Build/Compile
endef

define Package/watchping/install
        $(INSTALL_DIR) $(1)/
	$(CP) ./files/* $(1)/
endef
define Package/watchping/postinst
#!/bin/sh
# check if we are on real system
if [ -z "${IPKG_INSTROOT}" ]; then
	echo "Fix the permissions for watchping"
	echo "Enabling rc.d symlink for watchping"
	/etc/init.d/watchping enable
fi
exit 0
endef
define Package/watchping/prerm
#!/bin/sh
# check if we are on real system
if [ -z "${IPKG_INSTROOT}" ]; then
	echo "Removing rc.d symlink for watchping"
	/etc/init.d/watchping disable
fi
exit 0
endef
$(eval $(call BuildPackage,watchping))
