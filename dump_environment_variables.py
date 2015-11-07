#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import ConfigParser


def main():
    def get_environment_variable_if_possible(key, default=None):
        return os.environ.get(key, default)

    if not get_environment_variable_if_possible("XCS_DERIVED_DATA_DIR"):
        return

    project_root = get_environment_variable_if_possible("XCS_DERIVED_DATA_DIR")
    with open(os.path.join(project_root, "env"), "w") as f:
        config = ConfigParser.SafeConfigParser()
        config.optionxform = str
        config.add_section("Xcode")

        app_name = get_environment_variable_if_possible("FULL_PRODUCT_NAME", "")
        config.set("Xcode", "ProductName", app_name)

        cfg = get_environment_variable_if_possible("CONFIGURATION", "")
        config.set("Xcode", "Configuration", cfg)

        target = get_environment_variable_if_possible("IPHONEOS_DEPLOYMENT_TARGET", "")
        config.set("Xcode", "DeploymentTarget", target)

        version = get_environment_variable_if_possible("XCODE_VERSION_ACTUAL", "")
        config.set("Xcode", "Version", version)

        config.write(f)


if __name__ == "__main__":
    main()
