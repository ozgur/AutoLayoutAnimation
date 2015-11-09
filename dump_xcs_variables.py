#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import sys
import ConfigParser


def main():
    def get_environment_variable_if_possible(key, default=None):
        return os.environ.get(key, default)

    if not get_environment_variable_if_possible("XCS_DERIVED_DATA_DIR"):
        return

    path = os.path.join(
        get_environment_variable_if_possible("XCS_DERIVED_DATA_DIR"),
        sys.argv[1]
    )

    parser = ConfigParser.SafeConfigParser()
    parser.optionxform = str

    with open(path, "w") as f:
        parser.add_section("Xcode")

        app = get_environment_variable_if_possible("FULL_PRODUCT_NAME", "")
        parser.set("Xcode", "ProductName", app)

        config = get_environment_variable_if_possible("CONFIGURATION", "")
        parser.set("Xcode", "Configuration", config)

        target = get_environment_variable_if_possible(
            "IPHONEOS_DEPLOYMENT_TARGET", "")
        parser.set("Xcode", "DeploymentTarget", target)

        version = get_environment_variable_if_possible(
            "XCODE_VERSION_ACTUAL", "")
        parser.set("Xcode", "Version", version)

        parser.write(f)

if __name__ == "__main__":
    main()
