require 'rubygems'
require 'spec/rake/spectask'

require 'merb-core'
require 'merb-core/tasks/merb'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name        = 'kin'
    s.platform    = Gem::Platform::RUBY
    s.has_rdoc    = false
    s.summary     = 'Components commonly used in Showcase which can be ' +
                    'applied to other projects.'
    s.description = s.summary
    s.author      = 'Anthony Williams'
    s.email       = 'anthony@ninecraft.com'

    s.extra_rdoc_files = ['README', 'CHANGELOG', 'LICENSE']

    s.files = %w(LICENSE README CHANGELOG Rakefile VERSION.yml) +
              Dir.glob("{lib,spec}/**/*") - %w(spec/merb_test.log)
  end
rescue LoadError
  puts 'Jeweler not available. Install it with: gem install ' +
       'technicalpickles-jeweler -s http://gems.github.com'
end

##############################################################################
# rSpec & rcov
##############################################################################

desc "Run all examples (or a specific spec with TASK=xxxx)"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_opts  = ["-c -f s"]
  t.spec_files = begin
    if ENV["TASK"]
      ENV["TASK"].split(',').map { |task| "spec/**/#{task}_spec.rb" }
    else
      FileList['spec/**/*_spec.rb']
    end
  end
end

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new('spec:rcov') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.spec_opts = ['-c -f s']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec']
end

##############################################################################
# YARD Documentation
##############################################################################

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files = %w( CHANGELOG LICENSE lib/**/*.rb )
  end
rescue LoadError
  puts 'Yardoc not available. Install it with: gem install yardoc'
end