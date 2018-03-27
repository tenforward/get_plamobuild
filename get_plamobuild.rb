#!/usr/bin/ruby
require 'systemu'

PACKAGEINFO_DIR = "/var/log/packages"

$packages = Array.new

def get_packages()
  Dir.open(PACKAGEINFO_DIR).each do |p|
    $packages.push(p)
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

#get_packages
p get_category("lxc")

p $packages
