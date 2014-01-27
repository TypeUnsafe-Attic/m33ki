#!/bin/sh
# Copyright (c) 2014 Philippe Charrière aka @k33g_org
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

pulldown "https://raw2.github.com/dhg/Skeleton/master/stylesheets/base.css" -o stylesheets
pulldown "https://raw2.github.com/dhg/Skeleton/master/stylesheets/layout.css" -o stylesheets
pulldown "https://raw2.github.com/dhg/Skeleton/master/stylesheets/skeleton.css" -o stylesheets

pulldown "https://github.com/dhg/Skeleton/blob/master/images/apple-touch-icon-114x114.png" -o images
pulldown "https://github.com/dhg/Skeleton/blob/master/images/apple-touch-icon-72x72.png" -o images
pulldown "https://github.com/dhg/Skeleton/blob/master/images/apple-touch-icon.png" -o images
pulldown "https://github.com/dhg/Skeleton/blob/master/images/favicon.ico" -o images

pulldown "https://raw.github.com/coreyti/showdown/master/src/showdown.js" -o js/vendors


# === react =========================
#   http://facebook.github.io/react
# ===================================
pulldown "http://cdnjs.cloudflare.com/ajax/libs/react/0.8.0/JSXTransformer.js" -o js/vendors
pulldown "http://cdnjs.cloudflare.com/ajax/libs/react/0.8.0/react-with-addons.min.js" -o js/vendors
pulldown "http://cdnjs.cloudflare.com/ajax/libs/react/0.8.0/react.min.js" -o js/vendors

# https://github.com/seiffert/require-jsx
pulldown "https://raw2.github.com/seiffert/require-jsx/master/jsx.js" -o js/vendors



