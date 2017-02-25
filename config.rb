require 'sass-globbing'
require 'susy'

#TODO: Different config options on production staging server
project_type = :stand_alone
environment = :development
http_path = '/'
sass_dir = 'sass'
css_dir = 'css'
images_dir = 'image'
fonts_dir = 'font'
javascripts_dir = 'js'
sourcemap = true
preferred_syntax = :scss
output_style = :expanded
relative_assets = true