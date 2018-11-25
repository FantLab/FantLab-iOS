#!/usr/bin/env ruby

require 'fileutils'

def make_model_from(name, proto)
	content = ""
	content << "public final class #{name} {\n"
	proto.each do |key, value|
		content << "public let #{key}: #{value}\n"
	end
	content << "\npublic init("
	proto.each_with_index do |(key, value), index|
		content << "#{key}: #{value}"
		if index < proto.size - 1
			content << ",\n"
		end
	end
	content << ") {\n\n"
	proto.each do |key, value|
		content << "self.#{key} = #{key}\n"
	end
	content << "}\n}\n"
end
