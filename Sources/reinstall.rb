#!/usr/bin/env ruby

require 'fileutils'

load 'Utils/make_modules.rb'

FileUtils.rm_rf('Modules.xcodeproj')

if install_modules('Modules', 'Modules.yaml', '11.0')
	system('bundle exec pod deintegrate FantLab-iOS.xcodeproj')
	system('bundle exec pod install')

	patch_modules('Modules')
end
