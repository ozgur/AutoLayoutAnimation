#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import tempfile
import ConfigParser

if __name__ == '__main__':
    path = os.path.join(os.environ.get('TMPDIR', tempfile.gettempdir()), 'env')
    with open(path, 'w') as f:
        config = ConfigParser.SafeConfigParser()
        config.optionxform = str
        config.add_section('Xcode')
        config.set('Xcode', 'ProductName', os.environ.get('FULL_PRODUCT_NAME', ''))
        config.set('Xcode', 'Configuration', os.environ.get('CONFIGURATION', ''))
        config.write(f)
        os.environ['ENV_VARIABLES_PATH'] = path
