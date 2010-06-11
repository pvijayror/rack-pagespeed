require 'tmpdir'

class Rack::Bundle::FileSystemStore
  attr_accessor :dir, :bundles
  
  def initialize dir = Dir.tmpdir
    @dir = dir
    @bundles = []    
  end
  
  def has_bundle? bundle
    File.exists? "#{dir}/rack-bundle-#{bundle.hash}.#{bundle.extension}"
  end
    
  def save!
    @bundles.each do |bundle|
      next if has_bundle? bundle
      File.open("#{dir}/rack-bundle-#{bundle.hash}.#{bundle.extension}", 'w') do |file|
        file << bundle.contents
      end
    end
  end  
end