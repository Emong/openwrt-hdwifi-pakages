#
# Copyright (C) 2010 Jo-Philipp Wich <xm@subsignal.org>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=myddns
PKG_RELEASE:=1.0.0

PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/myddns
  SECTION:=base
  CATEGORY:=Base system
  TITLE:=myddns - Emong's ddns
  MAINTAINER:=Emong <emongxx@gmail.com>
endef

define Package/myddns/description
 Emong's ddns.
endef

define Package/myddns/conffiles
/etc/config/myddns
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/myddns/install
	$(INSTALL_DIR) $(1)
	$(CP) ./files/* $(1)
endef

define Package/myddns/postinst
#!/bin/sh
# check if we are on real system
if [ -z "$${IPKG_INSTROOT}" ]; then
        /etc/init.d/myddns disable
fi
exit 0
endef

define Package/myddns/prerm
#!/bin/sh
# check if we are on real system
if [ -z "$${IPKG_INSTROOT}" ]; then
        echo "removing myddns hotplug and crontabs.."
        /etc/init.d/myddns disable
fi
exit 0
endef


$(eval $(call BuildPackage,myddns))
