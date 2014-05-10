#
# Copyright (C) 2010 Jo-Philipp Wich <xm@subsignal.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ghca
PKG_RELEASE:=1.2.2009.2

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/ghca/default

endef

define Package/ghca
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Ghca - Calculate your Encoded Account
  MAINTAINER:=Emong <emongxx@gmail.com>
  $(Package/ghca/default)
endef

define Package/ghca/description
 Ghca Enable you run Ghcadial in your openwrt router.
endef


define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/ghca/conffiles
endef

define Package/ghca/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ghca $(1)/usr/bin/ghcadia
	$(CP) ./files/* $(1)
endef

define Package/ghca/postinst
#!/bin/sh
       /etc/init.d/ghca disable
exit 0
endef


$(eval $(call BuildPackage,ghca))
