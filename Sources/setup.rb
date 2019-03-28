#!/usr/bin/env ruby

require 'fileutils'
require 'xcodeproj'
require 'nanaimo'
require 'pathname'
require 'yaml'

def traverse_graph(graph, path, vertex, cycles)
	return if cycles.length > 0

	graph[vertex].each_with_index do |x, i|
		next if x == 0

		if path.include?(i)
			cycles.push(path + [i])

			return
		end

		traverse_graph(graph, path + [i], i, cycles)
	end
end

def find_dependency_cycle(modules)
	names = modules.keys.sort

	n = names.length

	graph = []

	for i in (0...n)
		row = []

		dependencies = (modules[names[i]]['dependencies'] || []).sort

		for j in (0...n)
			row.push(dependencies.include?(names[j]) ? 1 : 0)
		end

		graph.push(row)
	end

	cycles = []

	for i in (0...graph.length)
		traverse_graph(graph, [i], i, cycles)
	end

	cycle = cycles.first

	return cycle != nil ? cycle.map { |i| names[i] } : nil
end

def setup_group_content(parent_group, dir)
	compile_files = []

	for entry in Dir.glob("#{dir}/*")
		basename = File.basename(entry)

		if File.directory?(entry)
			group = parent_group.new_group(basename)
			group.set_path(basename)
			compile_files = compile_files + setup_group_content(group, entry)
		end

		if File.file?(entry) and File.extname(entry) == '.swift'
			file = parent_group.new_file(entry)
			file.set_path(basename)
			compile_files.push(file)
		end
	end

	return compile_files
end

def self.setup_build_settings(project, ios_version)
	for config in project.build_configurations
		config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
		config.build_settings['SWIFT_VERSION'] = '5.0'
		config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = ios_version

		if config.name != 'Release'
			config.build_settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = 'DEBUG'
		end
	end

	for target in project.targets
		for config in target.build_configurations
			config.build_settings['OTHER_LDFLAGS'] = '$(inherited)'
			config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf-with-dsym'
			config.build_settings['ENABLE_BITCODE'] = 'NO'

			if config.name == 'Debug'
				config.build_settings['SWIFT_COMPILATION_MODE'] = 'singlefile'
				config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Onone'
			else
				config.build_settings['SWIFT_COMPILATION_MODE'] = 'wholemodule'
				config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Osize'
			end
		end
	end
end

def make_modules_project(project_name, modules, ios_version)
	project = Xcodeproj::Project.new("#{project_name}.xcodeproj")
	project.add_build_configuration('Adhoc', :release)

	root_group = project.new_group('Sources')

	targets_table = {}

	modules.each do |target_name, config|
		target = project.new_target(:static_library, target_name, :ios, ios_version, nil, :swift)
		group = root_group.new_group(config['display_name'] || target_name)
		dir = config['sources']
		group.set_path(dir)
		compile_files = setup_group_content(group, dir)
		target.add_file_references(compile_files)
		targets_table[target_name] = target
	end

	modules.each do |target_name, config|
		target = targets_table[target_name]

		for dependency in config['dependencies'] || []
			dependency_target = targets_table[dependency]
			target.add_dependency(dependency_target)
			target.frameworks_build_phase.add_file_reference(dependency_target.product_reference, true)
		end
	end

	root_group.sort_recursively_by_type()

	setup_build_settings(project, ios_version)

	project.save()
end

def install_modules(project_name, yaml_path, ios_version)
	modules = YAML.load_file(yaml_path)

	dependency_cycle = find_dependency_cycle(modules)

	if dependency_cycle != nil
		puts "Dependency cycle was found: #{dependency_cycle.join(' -> ')}"

		return false
	else
		make_modules_project(project_name, modules, ios_version)

		return true
	end
end

def patch_modules(project_name)
	project = Xcodeproj::Project.open("#{project_name}.xcodeproj")

	for target in project.targets
		for build_phase in target.build_phases
			name = build_phase.display_name

			if name == '[CP] Copy Pods Resources' or name == '[CP] Check Pods Manifest.lock'
				build_phase.remove_from_project
			end
		end
	end

	project.recreate_user_schemes(false)

	project.save()
end

if install_modules('Modules', 'Modules.yaml', '11.0')
	system('bundle exec pod install')

	patch_modules('Modules')
end
