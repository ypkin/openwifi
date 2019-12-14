include $(TOPDIR)/rules.mk

PKG_NAME:=smartcapwap
PKG_VERSION:=1.0
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/smartcapwap
  SECTION:=net
  SUBMENU:=capwap
  CATEGORY:=Network
  TITLE:=Smartcapwap AC
  DEPENDS:=libnl-tiny +libcyassl +libxml2 +libconfig +libjson-c +libev \
		+@CYASSL_HAS_DTLS +@CYASSL_HAS_AES_CCM +@CYASSL_HAS_AES_GCM \
		+@CYASSL_HAS_CHACHA +@CYASSL_HAS_ECC +@CYASSL_HAS_DH \
		+@CYASSL_HAS_PSK +@CYASSL_HAS_ECC25519 +@CYASSL_HAS_POLY_1305 \
		+kmod-smartcapwap
endef

define Package/smartcapwap/description
	An ac for freewtp
endef

define KernelPackage/smartcapwap
  SUBMENU:=Network Support
  TITLE:=Smartcapwap Data Channel Module
  FILES:=$(PKG_BUILD_DIR)/kmod/smartcapwap.ko
  AUTOLOAD:=$(call AutoLoad,70,smartcapwap)
endef

define Build/Prepare
	$(INSTALL_DIR) $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

CMAKE_OPTIONS = -DOPENWRT=1
CMAKE_BINARY_DIR = $(PKG_BUILD_DIR)/ac
CMAKE_SOURCE_DIR = $(PKG_BUILD_DIR)/ac
MAKE_PATH = ac

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/libnl-tiny -I$(STAGING_DIR)/usr/include/libxml2

define Build/Compile/ac
	$(Build/Compile/Default, all)
endef

define Build/Compile/kmod
	+$(MAKE) $(PKG_JOBS) -C "$(LINUX_DIR)" \
		ARCH="$(LINUX_KARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		SUBDIRS="$(PKG_BUILD_DIR)/kmod" \
		modules
endef

define Build/Compile
	$(Build/Compile/ac)
	$(Build/Compile/kmod)
endef

define Package/smartcapwap/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/capwap
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ac/ac $(1)/usr/sbin
	$(INSTALL_CONF) ./files/ac.conf $(1)/etc/capwap
	$(INSTALL_DATA) ./files/ac.crt $(1)/etc/capwap
	$(INSTALL_DATA) ./files/ac.key $(1)/etc/capwap
	$(INSTALL_DATA) ./files/ca.crt $(1)/etc/capwap
endef

$(eval $(call BuildPackage,smartcapwap))
$(eval $(call KernelPackage,smartcapwap))
