require 'rubygems'
require 'spec/rake/spectask'

require 'merb-core'
require 'merb-core/tasks/merb'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name        = 'showcase-common'
    s.platform    = Gem::Platform::RUBY
    s.has_rdoc    = false
    s.summary     = 'Components commonly used in Showcase which can be ' +
                    'applied to other projects.'
    s.description = s.summary
    s.author      = 'Anthony Williams'
    s.email       = 'anthony@ninecraft.com'

    s.extra_rdoc_files = ['README', 'LICENSE']

    s.files = %w(LICENSE README Rakefile VERSION.yml) +
              Dir.glob("{lib,spec}/**/*")
  end
rescue LoadError
  puts 'Jeweler not available. Install it with: sudo gem install ' +
       'technicalpickles-jeweler -s http://gems.github.com'
end

##############################################################################
# rSpec & rcov
##############################################################################

desc "Run all examples"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.spec_opts = ['-c -f s']
end

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new('spec:rcov') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.spec_opts = ['-c -f s']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end
