Pod::Spec.new do |s|
	s.name     = 'GRDB'
	s.version  = '3.6.2'
	
	s.license  = { :type => 'MIT', :file => 'LICENSE' }
	s.summary  = 'A Swift application toolkit for SQLite databases.'
	s.homepage = 'https://github.com/groue/GRDB.swift'
	s.author   = { 'Gwendal Roué' => 'gr@pierlis.com' }
	s.source   = { :git => 'https://github.com/groue/GRDB.swift.git', :tag => "v#{s.version}" }
	s.module_name = 'GRDB'
	
	s.ios.deployment_target = '8.0'
	s.osx.deployment_target = '10.9'
	s.watchos.deployment_target = '2.0'
	
	s.source_files = 'GRDB/**/*.swift', 'Support/sqlite3.h', 'Support/grdb_config.c', 'Support/grdb_config.h'
	s.framework = 'Foundation'
	s.library = 'sqlite3'
end
