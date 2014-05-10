#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ghca_catch
PKG_VERSION:=1.2
PKG_RELEASE:=1


PKG_BUILD_DEPENDS:=ppp

include $(INCLUDE_DIR)/package.mk

define Package/ghca_catch
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+ppp +libpthread
  TITLE:=emong_catch_ghca_account
  URL:=http://roaringpenguin.com/products/pppoe
#  SUBMENU:=dial-in/up
endef

define Package/ghca_catch/Default/description
  Will automatic catch ghca dialer packets.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

TARGET_CFLAGS += -I$(PKG_BUILD_DIR)/src/libevent
CONFIGURE_PATH := ./src
CONFIGURE_ARGS += ac_cv_path_PPPD=/usr/sbin/pppd --enable-plugin=$(STAGING_DIR)/usr/include/
MAKE_FLAGS := DESTDIR="$(PKG_INSTALL_DIR)" install
MAKE_PATH := ./src

define Package/ghca_catch/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/pppoe-relay $(1)/usr/sbin/ghca-catch
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/pppoe-server $(1)/usr/sbin/ghca-server
endef

$(eval $(call BuildPackage,ghca_catch))
