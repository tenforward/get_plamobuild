#!/usr/bin/ruby
# coding: utf-8
require 'systemu'

PACKAGEINFO_DIR = "/var/log/packages"
DOCDIR = "/usr/share/doc"
REPO_DIR = "./Plamo-src"
FAIL_FILE = "./failure.txt"
LOCATION = "/var/adm/mount/plamo/"

def get_package_infos()
  Dir.glob("#{PACKAGEINFO_DIR}/*") do |f|
    package_name = f.delete_prefix("#{PACKAGEINFO_DIR}/").chomp
    puts "=== #{package_name} ==="
    io = open(f, "r")
    while line = io.gets
      if /PACKAGE NAME:\s+(.*?)-(.*?)-(.*?)-(.*)/ =~ line then
        version = $2
      end
      if %r{PACKAGE LOCATION:\s+(.+)/([0-9a-z_]+?)/} =~ line then
        category = $2
      end
      if /PlamoBuild/ =~ line then
        script_path = "/#{line}".chomp
        script = File.basename(script_path)
      end
    end
    if category.nil? || category.empty? then
      log = open("failure.txt", "a")
      log.seek(0, IO::SEEK_END)
      log.puts("#{package_name}: no category")
      log.close
    elsif script_path.nil? || script_path.empty? then
      log = open("failure.txt", "a")
      log.seek(0, IO::SEEK_END)
      log.puts("#{package_name}: No PlamoBuild")
      log.close
    else
      to_dir = "#{REPO_DIR}/#{category}/#{package_name}"
      FileUtils.mkdir_p(to_dir, {:verbose => true})
      FileUtils.copy(script_path, to_dir, {:verbose => true})
    end
    io.close
  end
end

get_package_infos
