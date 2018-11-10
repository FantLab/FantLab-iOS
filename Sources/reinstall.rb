#!/usr/bin/env ruby

require 'fileutils'

load 'Utils/make_modules.rb'

if install_modules('Modules', 'Modules.yaml', '9.0')
	system('bundle exec pod deintegrate FantLab-iOS.xcodeproj')
	system('bundle exec pod install')

	patch_modules('Modules')
end
