include $(TOPDIR)/rules.mk

PKG_NAME:=zzz-MESHdesk
PKG_VERSION:=5.6.0
PKG_RELEASE:=0

include $(INCLUDE_DIR)/package.mk

define Package/zzz-MESHdesk
   SUBMENU:=Wifimedia
   SECTION:=dev
   CATEGORY:=Advance
   TITLE:=MESHdesk firmware
   URL:=http://radiusdesk.com/
   MENU:=1
   PKGARCH:=all
endef


define Package/zzz-MESHdesk/description
MESHdesk is parrt of RADIUSdesk
endef

define Build/Compile
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
endef

define Package/zzz-MESHdesk/install
   	$(INSTALL_DIR) $(1)/etc/MESHdesk
	$(INSTALL_DIR) $(1)/etc/MESHdesk/alfred_scripts
	$(INSTALL_DIR) $(1)/etc/MESHdesk/captive_portals
	$(INSTALL_DIR) $(1)/etc/MESHdesk/configs
	#$(INSTALL_DIR) $(1)/etc/MESHdesk/files
	$(INSTALL_DIR) $(1)/etc/MESHdesk/libs
	$(INSTALL_DIR) $(1)/etc/MESHdesk/tests
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	cp -r ./files/alfred_scripts/* $(1)/etc/MESHdesk/alfred_scripts
	#cp -r ./files/captive_portals/* $(1)/etc/MESHdesk/captive_portals
	cp -r ./files/configs/* $(1)/etc/MESHdesk/configs
	#cp -r ./files/* $(1)/etc/MESHdesk/files
	cp -r ./files/libs/* $(1)/etc/MESHdesk/libs
	cp -r ./files/tests/* $(1)/etc/MESHdesk/tests
	$(INSTALL_BIN) ./files/a.lua $(1)/etc/MESHdesk/
	$(INSTALL_BIN) ./files/actions_checker.lua $(1)/etc/MESHdesk/
	$(INSTALL_BIN) ./files/batman_neighbours.lua $(1)/etc/MESHdesk/
	$(INSTALL_BIN) ./files/heartbeat.lua $(1)/etc/MESHdesk/
	$(INSTALL_BIN) ./files/hotplug_lan.lua $(1)/etc/MESHdesk/
	$(INSTALL_BIN) ./files/led.lua $(1)/etc/MESHdesk/
	$(INSTALL_BIN) ./files/main_led.lua $(1)/etc/MESHdesk/
	$(INSTALL_DATA) ./files/meshdeskcontrol.lua $(1)/usr/lib/lua/luci/controller/meshdesk.lua
	$(INSTALL_DATA) ./files/meshdeskcbi.lua $(1)/usr/lib/lua/luci/model/cbi/meshdesk.lua
	mkdir -p $(1)/etc/init.d
	#$(INSTALL_DATA) ./files/md_prerun $(1)/etc/init.d
	$(INSTALL_BIN) ./files/apstart $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/media_uci_default $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/md_prerun $(1)/etc/init.d
	mkdir -p $(1)/etc/config
	$(INSTALL_DATA) ./files/meshdesk $(1)/etc/config
	mkdir -p $(1)/etc/hotplug.d/iface
	cp ./files/common/70-meshdesk $(1)/etc/hotplug.d/iface/
	mkdir -p $(1)/etc/alfred
	cp ./files/alfred_scripts/alfred_meshdesk_scripts.sh $(1)/etc/alfred
	mkdir -p $(1)/etc/chilli/www
	cp ./files/common/radiusdesk.html $(1)/etc/chilli/www
endef

define Package/zzz-MESHdesk/postinst
#!/bin/sh
exit 0
endef

define Package/zzz-MESHdesk/prerm
#!/bin/sh
# check if we are on real system
if [ -z "$${IPKG_INSTROOT}" ]; then
        echo "Removing rc.d symlink for MESHdesk"
        /etc/init.d/md_prerun disable
		echo "Fix the permissions for wifimesh"
		chmod +x /etc/MESHdesk/alfred_scripts/*
fi
exit 0
endef

$(eval $(call BuildPackage,zzz-MESHdesk))
