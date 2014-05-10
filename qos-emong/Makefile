# 
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qos-emong
PKG_VERSION:=1.0.2
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/qos-emong
  SECTION:=utils
  CATEGORY:=Base system
  DEPENDS:=+tc +kmod-sched +kmod-ifb +iptables +iptables-mod-filter +iptables-mod-ipopt +iptables-mod-conntrack-extra +iptables-mod-opendpi
  TITLE:=Emong's QoS scripts
  PKGARCH:=all
endef

define Package/qos-emong/description
 Qos comes from emong.
endef

define Package/qos-emong/conffiles
/etc/config/qos
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/qos-emong/install
	$(INSTALL_DIR) $(1)
	$(CP) ./files/* $(1)/
endef

$(eval $(call BuildPackage,qos-emong))
