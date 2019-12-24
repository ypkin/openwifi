#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=scheduled
PKG_VERSION:=1.2.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Dungtd <dungtd8x@gmail.com>
PKG_LICENSE:=GPLv2

include $(INCLUDE_DIR)/package.mk

define Package/scheduled
  SUBMENU:=Wifimedia
  SECTION:=dev
  CATEGORY:=Advance
  TITLE:=scheduled
  URL:=http://wifimedia.vn
  MENU:=1
  PKGARCH:=all
  MAINTAINER:=DungTD <dungtd8x@gmail.com>
endef

define Package/scheduled/description

endef

define Build/Compile
endef

define Package/scheduled/install
	$(INSTALL_DIR) $(1)/root
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller/wifimedia
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/wifimedia_module
	$(INSTALL_DATA) ./files/scheduled_conf $(1)/etc/config/scheduled
	$(INSTALL_BIN) ./files/scheduled_uci $(1)/etc/uci-defaults/scheduled
	$(INSTALL_BIN) ./files/scheduled.sh $(1)/usr/bin/scheduled.sh
	$(INSTALL_DATA) ./files/scheduled_controller.lua $(1)/usr/lib/lua/luci/controller/wifimedia/scheduled.lua
	$(INSTALL_DATA) ./files/scheduled_model.lua $(1)/usr/lib/lua/luci/model/cbi/wifimedia_module/scheduled.lua
endef


define Package/scheduled/postinst
#!/bin/sh
# check if we are on real system
if [ -z "${IPKG_INSTROOT}" ]; then
	echo "Fix the permissions for scheduled"
	chmod a+x /usr/bin/scheduled.sh
fi
exit 0
endef

$(eval $(call BuildPackage,scheduled))