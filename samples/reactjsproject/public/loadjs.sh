#!/bin/sh
# Copyright (c) 2013 Philippe Charrière aka @k33g_org
#
# All rights reserved. No warranty, explicit or implicit, provided.
#

pulldown "https://raw.github.com/amdjs/underscore/master/underscore-min.js" -o js/vendors
pulldown "https://raw.github.com/amdjs/backbone/master/backbone-min.js" -o js/vendors
pulldown jquery -o js/vendors
pulldown require.js -o js/vendors
#pulldown require-text -o js/vendors
pulldown "https://raw.github.com/requirejs/domReady/latest/domReady.js" -o js/vendors
pulldown "https://raw.github.com/requirejs/text/master/text.js" -o js/vendors
pulldown "https://raw.github.com/coreyti/showdown/master/src/showdown.js" -o js/vendors






