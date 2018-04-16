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
    package_name = f.delete_prefix("#{PACKAGEINFO_DIR}/")
    io = open(f, "r")
    while line = io.gets
      if /PACKAGE NAME:\s+(.*?)-(.*?)-(.*?)-(.*)/ =~ line then
        version = $2
      end
      if %r{PACKAGE LOCATION:\s+(.+)/([0-9a-z_]+?)/} =~ line then
        category = $2
      end
      if /PlamoBuild/ =~ line then
        script = "/#{line}"
      end
    end
    puts "plamo/#{category}/#{package_name}/"
    io.close
  end
end

def get_category(package)
  pkg_file = "#{PACKAGEINFO_DIR}/#{package}"
  res = systemu("grep 'PACKAGE LOCATION' #{pkg_file} | awk '{ print $3 }'")
  if !res[0].success? then
    return false
  end
  if /\/var\/adm\/mount\/plamo\/(\d+_\w+)\// =~ res[1] then
    return $1
  end
  $stderr.puts("\"#{package}\" does not includes category info.")
  return false
end

def copy_buildscript()
  # docdir の PlamoBuild.* をサーチ
  Dir.glob("#{DOCDIR}/*/PlamoBuild.*.gz").each do |fullpath|
    if /(.*)\/(PlamoBuild.*)/ =~ fullpath.delete_prefix("#{DOCDIR}/") then
      script_gz = $2
      script = script_gz.delete_suffix(".gz")
      if /(.*)-([0-9.-_]+)/ =~ script then
        package = $1.delete_prefix("PlamoBuild.").tr("-", "_")
        version = $2
      end
      if !FileTest.exist?("#{PACKAGEINFO_DIR}/#{package}") then
        io = open(FAIL_FILE, "a")
        io.seek(0, IO::SEEK_END)
        io.puts("Script: #{script}\t\tPackage: #{package}\t\tVersion: #{version}")
        io.close
      end
      puts "Script: #{script}\t\tPackage: #{package}\t\tVersion: #{version}"
    end
  end
end

#copy_buildscript
get_package_infos
