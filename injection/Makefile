#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=injection
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Dungtd <dungtd8x@gmail.com>
PKG_LICENSE:=GPLv2

include $(INCLUDE_DIR)/package.mk

define Package/injection
  SUBMENU:=Wifimedia
  SECTION:=dev
  CATEGORY:=Advance
  DEPENDS:=+luci +luci-mod-admin-full
  TITLE:=injection ...
  URL:=http://wifimedia.vn
  MENU:=1
  PKGARCH:=all
  MAINTAINER:=DungTD <dungtd8x@gmail.com>
endef

define Package/injection/description

endef

define Build/Compile
endef

define Package/injection/install
	$(INSTALL_DIR) $(1)
	$(CP) ./files/* $(1)
endef

define Package/injection/postinst
#!/bin/sh
# check if we are on real system
if [ -z "${IPKG_INSTROOT}" ]; then
	chmod a+x /sbin/wifimedia/injection.sh	
fi
exit 0
endef

define Package/injection/prerm
#!/bin/sh
# check if we are on real system
if [ -z "${IPKG_INSTROOT}" ]; then
	echo "injection..."
fi
exit 0
endef

$(eval $(call BuildPackage,injection))