require 'find'

namespace :build do

  desc 'Builds the documentation using YARD'
  task :doc do
    gem_path = File.expand_path('../../', __FILE__)
    command  = "yard doc #{gem_path}/lib -m markdown -M rdiscount -o #{gem_path}/doc "
    command += "-r #{gem_path}/README.md --private --protected "
    command += "--files #{gem_path}/license.txt"

    sh(command)
  end

  desc 'Builds a new Gem'
  task :gem do
    gem_path = File.expand_path('../../', __FILE__)

    # Build and install the gem
    sh("gem build #{gem_path}/beehive.gemspec")
    sh("mv #{gem_path}/beehive-#{Beehive::Version}.gem #{gem_path}/pkg")
    sh("gem install #{gem_path}/pkg/beehive-#{Beehive::Version}.gem")
  end

  desc 'Builds the MANIFEST file'
  task :manifest do
    gem_path     = File.expand_path('../../', __FILE__)
    ignore_exts  = ['.gem', '.gemspec', '.swp']
    ignore_files = ['.DS_Store', '.gitignore', 'output']
    ignore_dirs  = ['.git', '.yardoc', 'pkg', 'doc']
    files        = ''
    
    Find.find(gem_path) do |f|
      f[gem_path] = ''
      f.gsub!(/^\//, '')

      # Ignore directories
      if !File.directory?(f) and !ignore_exts.include?(File.extname(f)) and !ignore_files.include?(File.basename(f))
        files += "#{f}\n"
      else
        Find.prune if ignore_dirs.include?(f)
      end
    end
    
    # Time to write the MANIFEST file
    begin
      handle = File.open 'MANIFEST', 'w'
      handle.write files.strip
      puts "The MANIFEST file has been updated."
    rescue
      abort "The MANIFEST file could not be written."
    end
  end

end
