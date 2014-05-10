# 
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=yunwifi-bwcontrol
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/yunwifi-bwcontrol
  SECTION:=utils
  CATEGORY:=Base system
  DEPENDS:=+tc +kmod-sched +kmod-ifb +iptables-mod-filter +iptables-mod-ipopt +iptables-mod-conntrack-extra +yunwifi-root
  TITLE:=Yunwifi bandwidth tools
  PKGARCH:=all
endef

define Package/yunwifi-bwcontrol/description
 yunwifi bandwidth scripts,works with wifidog.
endef

define Package/yunwifi-bwcontrol/conffiles
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/yunwifi-bwcontrol/install
	$(INSTALL_DIR) $(1)
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,yunwifi-bwcontrol))
