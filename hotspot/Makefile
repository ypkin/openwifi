#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=hotspot
PKG_VERSION:=2.1.2
PKG_RELEASE:=3
PKG_MAINTAINER:=Dungtd <dungtd8x@gmail.com>
PKG_LICENSE:=GPLv2

include $(INCLUDE_DIR)/package.mk

define Package/hotspot
  SUBMENU:=Wifimedia
  SECTION:=dev
  CATEGORY:=Advance
  DEPENDS:=+coova-chilli +luci +luci-mod-admin-full +luci-theme-material
  TITLE:=Wireless LAN HotSpot controller
  URL:=http://wifimedia.vn
  MENU:=1
  PKGARCH:=all
  MAINTAINER:=DungTD <dungtd8x@gmail.com>
endef

define Package/hotspot/description
	Wifimedia offer it supports Wireless
	Protected Access (WPA) which is the standard of the future.
	Authentication,	authorization and accounting (AAA) is handled by your
	favorite radius server.
endef

define Build/Compile
endef

define Package/hotspot/install
	$(INSTALL_DIR) $(1)/etc/chilli
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/hotplug.d/button
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/sbin/wifimedia
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/wifimedia
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/wifimedia_module
	$(INSTALL_DATA) ./files/etc/chilli/defaults $(1)/sbin/wifimedia/defaults
	$(INSTALL_BIN) ./files/etc/init.d/chilli $(1)/etc/init.d/wifi_portal
	
	$(INSTALL_BIN) ./files/etc/init.d/update_ip $(1)/etc/init.d/update_ip
	$(INSTALL_BIN) ./files/etc/uci-defaults/hotspot $(1)/etc/uci-defaults/hotspot
	$(INSTALL_BIN) ./files/sbin/wifimedia/update_ip.sh $(1)/sbin/wifimedia/update_ip.sh
	
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/controller/wifimedia/hotspot.lua $(1)/usr/lib/lua/luci/controller/wifimedia/hotspot.lua
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/model/cbi/wifimedia_module/hotspot.lua $(1)/usr/lib/lua/luci/model/cbi/wifimedia_module/hotspot.lua	
	
endef

define Package/hotspot/postinst
#!/bin/sh
# check if we are on real system
if [ -z "${IPKG_INSTROOT}" ]; then
	echo "Fix the permissions for wifi_portal"
	chmod a+x /etc/init.d/wifi_portal
	chmod a+x /etc/rc.d/wifi_portal	
fi
exit 0
endef

define Package/hotspot/prerm
#!/bin/sh
# check if we are on real system
if [ -z "${IPKG_INSTROOT}" ]; then
	echo "Removing rc.d symlink for wifimedia"
	/etc/init.d/wifi_portal disable
fi
exit 0
endef

$(eval $(call BuildPackage,hotspot))