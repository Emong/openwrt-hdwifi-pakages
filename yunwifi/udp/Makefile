include $(TOPDIR)/rules.mk

PKG_NAME:=udphd
PKG_VERSION:=0.2
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/udphd-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/udphd
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+autossh
  TITLE:=HDWIFI UDP CONTROL UTINITY
  #DESCRIPTION:=This variable is obsolete. use the Package/name/description define instead!
  URL:=http://www.hdwifi.cn/
endef

define Package/udphd/description
	HDWIFI UDP CONTROL UTINITY
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/udphd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/udphd $(1)/usr/bin/udphd
	$(INSTALL_BIN) ./files/remote.sh $(1)/usr/bin/remote.sh
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/udphd.init $(1)/etc/init.d/udphd
endef

$(eval $(call BuildPackage,udphd))
