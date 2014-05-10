# 
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=yunwifi-root
PKG_VERSION:=0.0.1
PKG_RELEASE:=1

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/yunwifi-root
  SECTION:=utils
  CATEGORY:=Base system
  DEPENDS:=
  TITLE:=Yunwifi root
  PKGARCH:=all
endef

define Package/yunwifi-root/description
 yunwifi root,some files puts here.
endef

define Package/yunwifi-root/conffiles
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/yunwifi-root/install
	$(INSTALL_DIR) $(1)
	$(CP) ./files/* $(1)/
endef
define Package/yunwifi-root/postinst
#!/bin/sh
sed -i 's|exit 0|/etc/init.d/yunwifi-cron-autoup enable\nexit 0|g' /etc/rc.local
sed -i 's|exit 0|/etc/init.d/yunwifi-cron-whitelist enable\nexit 0|g' /etc/rc.local
sed -i 's|exit 0|whitelist.sh do_table\nexit 0|g' /etc/rc.local
endef
define Package/yunwifi-root/prerm
#!/bin/sh
sed -i '/yunwifi-cron-autoup/'d /etc/rc.local
sed -i '/yunwifi-cron-whitelist/'d /etc/rc.local
sed -i '/whitelist.sh/'d /etc/rc.local
endef

$(eval $(call BuildPackage,yunwifi-root))
