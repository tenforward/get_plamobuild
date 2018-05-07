#!/usr/bin/ruby
# coding: utf-8

require 'systemu'

PACKAGEINFO_DIR = "/var/log/packages"
DOCDIR = "/usr/share/doc"
REPO_DIR = "../Plamo-src/plamo"
FAIL_FILE = "./failure.txt"
LOCATION = "/var/adm/mount/plamo/"
PKGLISTFILE = "./package_list"

$related = ["patch", "init", "conf", "service", ".cf"]

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
        script_dir = File.dirname(script_path)
      end
    end
    
    if category.nil? || category.empty? then
      category = fallback_category(package_name)

      if !category then
        log = open("failure.txt", "a")
        log.seek(0, IO::SEEK_END)
        log.puts("#{package_name}: failure to get category")
        log.close
      end
    end
    
    if script_path.nil? || script_path.empty? then
      log = open("failure.txt", "a")
      log.seek(0, IO::SEEK_END)
      log.puts("#{package_name}: No PlamoBuild")
      log.close
    else
      to_dir = "#{REPO_DIR}/#{category}/#{package_name}"
      FileUtils.mkdir_p(to_dir, {:verbose => false})
      FileUtils.copy(script_path, to_dir, {:verbose => false})
      if File.extname(script_path) == ".gz" then
        file = File.basename(script_path)
        system("gzip -df #{to_dir}/#{file}")
      end
      get_related_files(script_dir).each do |file|
        FileUtils.copy("#{script_dir}/#{file}", to_dir, {:verbose => true})
        if File.extname(file) == ".gz" then
          system("gzip -df #{to_dir}/#{file}")
        end
      end
    end
    io.close
  end
end

def get_related_files(dir)
  files = Array.new
  Dir.open(dir).each do |o|
    if o == "." || o == ".." then
      next
    end
    if FileTest.directory?("#{dir}/#{o}") then
      next
    end
    $related.each do |pattern|
      if %r(#{pattern}) =~ o then
        files << o
      end
    end
  end
  return files
end

def fallback_category(pkgname)
  open(PKGLISTFILE, "r").each do |line|
    if /#{pkgname}.*\.txz/ =~ line
      line.chomp!
      if %r{/([0-9]+_[a-z0-9]+?)/} =~ line then
        return $1
      end
    end
  end
  return false
end

get_package_infos
#get_related_files("/usr/share/doc/dhcp-4.4.1/")
#puts fallback_category("font_xfree86_type1")
