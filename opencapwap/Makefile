include $(TOPDIR)/rules.mk

PKG_NAME:=opencapwap
PKG_VERSION:=2.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

define Package/opencapwap/Default
  SUBMENU:=Wifimedia
  SECTION:=dev
  CATEGORY:=Advance
  TITLE:=OpenCAPWAP
  DEPENDS:=+libpthread +libnl +libopenssl +kmod-tun
  MENU:=1
  PKGARCH:=all
  MAINTAINER:=DungTD <dungtd8x@gmail.com>  
endef

define Package/opencapwap-ac
	$(call Package/opencapwap/Default)
	TITLE += (AC)
endef

define Package/opencapwap-wtp
	$(call Package/opencapwap/Default)
	TITLE += (WTP)
endef

define Build/Prepare
	$(INSTALL_DIR) $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/libnl3 -g3

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) CC="$(TARGET_CC)" TARGET_CFLAGS="$(TARGET_CFLAGS)" TARGET_LDFLAGS="$(TARGET_LDFLAGS)"
	$(MAKE) -C $(PKG_BUILD_DIR)/wum CC="$(TARGET_CC)" TARGET_CFLAGS="$(TARGET_CFLAGS)" TARGET_LDFLAGS="$(TARGET_LDFLAGS)"
endef

define Package/opencapwap-ac/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/ac
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/AC $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wum/wum $(1)/usr/sbin/wum
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/settings.ac.txt $(1)/etc/ac
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/config.ac $(1)/etc/ac
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/server.pem $(1)/etc/ac
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/root.pem $(1)/etc/ac
endef

define Package/opencapwap-wtp/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/wtp
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/WTP $(1)/usr/sbin
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/settings.wtp.txt $(1)/etc/wtp
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/config.wtp $(1)/etc/wtp
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/client.pem $(1)/etc/wtp
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/root.pem $(1)/etc/wtp
endef

$(eval $(call BuildPackage,opencapwap-ac))
$(eval $(call BuildPackage,opencapwap-wtp))
