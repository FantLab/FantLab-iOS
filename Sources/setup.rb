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
	files_to_compile = []

	for entry in Dir.glob("#{dir}/*")
		basename = File.basename(entry)

		if File.directory?(entry)
			group = parent_group.new_group(basename)
			group.set_path(basename)
			files_to_compile = files_to_compile + setup_group_content(group, entry)
		end

		if File.file?(entry) and File.extname(entry) == '.swift'
			file = parent_group.new_file(entry)
			file.set_path(basename)
			files_to_compile.push(file)
		end
	end

	return files_to_compile
end

def setup_build_settings(project)
	for config in project.build_configurations
		config.build_settings['PRODUCT_NAME'] = '$(TARGET_NAME)'
		config.build_settings['SWIFT_VERSION'] = '4.2'
		config.build_settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = 'DEBUG'
	end

	for target in project.targets
		for config in target.build_configurations
			config.build_settings['OTHER_LDFLAGS'] = '$(inherited)'
			config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf-with-dsym'

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
		files_to_compile = setup_group_content(group, dir)
		target.add_file_references(files_to_compile)

		for system_framework in config['system_frameworks'] || []
			target.add_system_framework(system_framework)
		end

		targets_table[target_name] = target
	end

	modules.each do |target_name, config|
		module_target = targets_table[target_name]

		for dependency in config['dependencies'] || []
			target = targets_table[dependency]
			module_target.add_dependency(target)
			module_target.frameworks_build_phase.add_file_reference(target.product_reference, true)
		end
	end

	root_group.sort_recursively_by_type()

	setup_build_settings(project)

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

	project.save()
end

if install_modules('Modules', 'Modules.yaml', '11.0')
	system('bundle exec pod install')

	patch_modules('Modules')
end