#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import ConfigParser

if __name__ == "__main__":
    if "XCS_DERIVED_DATA_DIR" in os.environ:
        with open(os.path.join(os.environ["XCS_DERIVED_DATA_DIR"], "env"), "w") as f:
            config = ConfigParser.SafeConfigParser()
            config.optionxform = str
            config.add_section("Xcode")
            config.set("Xcode", "ProductName", os.environ.get("FULL_PRODUCT_NAME", ""))
            config.set("Xcode", "Configuration", os.environ.get("CONFIGURATION", ""))
            config.write(f)
            print "File is: %s" % os.path.join(os.environ.get("XCS_DERIVED_DATA_DIR"), "env")
