#!/usr/bin/ruby
require 'systemu'

PACKAGEINFO_DIR = "/var/log/packages"
DOCDIR = "/usr/share/doc"
REPO_DIR = "./Plamo-src"

def get_packages()
  packages = Array.new
  Dir.open(PACKAGEINFO_DIR).each do |package|
    if package == "." || package == ".." then
      next
    end
    packages.push(package)
  end
  return packages
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
  Dir.glob("#{DOCDIR}/*/PlamoBuild.*.gz").each do |script|
    puts script
  end
end

#p get_packages
#p get_src("lxc")
#p $packages
copy_buildscript
