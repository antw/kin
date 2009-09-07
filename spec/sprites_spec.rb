require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

sprites = File.join(File.dirname(__FILE__), '..', 'lib', 'kin', 'sprites')

require sprites
require File.join(sprites, 'rake_runner')

# IconSet ====================================================================

describe Kin::Sprites::IconSet do
  it 'should include Enumerable' do
    Kin::Sprites::IconSet.ancestors.should include(Enumerable)
  end

  describe '#each' do
    it 'should yield each icon in turn' do
      icons, yielded = %w(one two), []

      Kin::Sprites::IconSet.new(icons).each do |icon|
        yielded << icon
      end

      yielded.should == icons
    end
  end

  describe '#location_of' do
    before(:each) do
      @set = Kin::Sprites::IconSet.new(%w(one two))
    end

    it 'should return 0 if the given icon is first' do
      @set.location_of('one').should == 0
    end

    it 'should return 40 if the given icon is second' do
      @set.location_of('two').should == 40
    end
  end

  describe '#length' do
    it 'should return the number of icons in the set' do
      Kin::Sprites::IconSet.new([]).length.should == 0
      Kin::Sprites::IconSet.new(['one']).length.should == 1
      Kin::Sprites::IconSet.new(['one', 'two']).length.should == 2
    end
  end
end

# ImageGenerator =============================================================

# Requires:
#
# @gen (Kin::Sprites::ImageGenerator)
#   An image generator instance.
# @sprite_path (String)
#   A path to where a sprite should be saved.
#
describe 'saving a sprite', :shared => true do
  it 'should save the image to the specified path' do
    lambda { @gen.save(@sprite_path) }.should \
      change(&lambda { File.exists?(@sprite_path) })
  end

  it 'should silently overwrite any existing file at the specified path' do
    FileUtils.touch(@sprite_path)
    orig_size = File.size(@sprite_path)
    @gen.save(@sprite_path)

    # Using touch should create a zero-byte file (as near as makes no
    # difference, anyway). Saving the PNG should result in a larger file.
    File.exists?(@sprite_path).should be_true
    File.size(@sprite_path).should > orig_size
  end

  it 'should save a 32-bit PNG' do
    @gen.save(@sprite_path)
    image = Magick::Image.ping(@sprite_path).first
    image.format.should == 'PNG'
    image.quantum_depth.should == 8 # 8-bits per channel.
  end

  it 'should create a 16 pixel wide image' do
    @gen.save(@sprite_path)
    Magick::Image.ping(@sprite_path).first.columns.should == 16
  end
end

describe Kin::Sprites::ImageGenerator, '#save' do
  ##
  # Creates an ImageGenerator instance suitable for use in specs.
  #
  # @param [Array<String>] An array of icons to use.
  #
  def create_image_generator(icons)
    Kin::Sprites::ImageGenerator.new(
      Kin::Sprites::IconSet.new(icons),
      fixture_path('public', 'images', 'sprites', 'src')
    )
  end

  before(:all) do
    @dir = tmp_path('sprites')
    @sprite_path = tmp_path('sprites', 'sprite.png')
    FileUtils.mkdir_p(@dir)
  end

  after(:all) do
    FileUtils.rmdir(@dir)
  end

  after(:each) do
    FileUtils.rm(@sprite_path) if @sprite_path && File.exists?(@sprite_path)
  end

  # On with the specs...

  describe 'when creating a sprite with a single icon' do
    before(:each) do
      @gen = create_image_generator(['one'])
    end

    it_should_behave_like 'saving a sprite'

    it 'should create a 16 pixel high image' do
      # 40 pixels with the top and bottom 12 (blank) cropped off
      @gen.save(@sprite_path)
      Magick::Image.ping(@sprite_path).first.rows.should == 16
    end
  end

  describe 'when creating a sprite with a three icons' do
    before(:each) do
      @gen = create_image_generator(['one', 'two', 'three'])
    end

    it_should_behave_like 'saving a sprite'

    it 'should create a 96 pixel high image' do
      # 120 pixels with the top and bottom 12 (blank) cropped off
      @gen.save(@sprite_path)
      Magick::Image.ping(@sprite_path).first.rows.should == 96
    end
  end

  it 'should raise IconNotReadable when one of the icons does not exist' do
    block = lambda { create_image_generator(['not_here']).save(@sprite_path) }
    block.should raise_error(
      Kin::Sprites::ImageGenerator::IconNotReadable, /unable to open/)
  end

  it 'should raise TargetNotWriteable when the sprite path is not ' \
     'writeable' do
    gen = create_image_generator(['one'])
    orig_perms = File.stat(@dir).mode
    File.chmod(0000, @dir)

    begin
      lambda { gen.save(@sprite_path) }.should raise_error(
        Kin::Sprites::ImageGenerator::TargetNotWriteable, /Permission denied/)
    ensure
      File.chmod(orig_perms, @dir)
    end
  end
end

# SassGenerator ==============================================================

describe Kin::Sprites::SassGenerator, '#to_sass' do
  before(:each) do
    @set  = Kin::Sprites::IconSet.new(%w(one two three))
    @gen  = Kin::Sprites::SassGenerator.new(@set, 'mysprites')
    @sass = @gen.to_sass('/images/sprites')
  end

  it 'should not indent mixin definitions' do
    @sass.each_line do |line|
      line.should =~ /^=/ if line =~ /=\w+-icon/
    end
  end

  it 'should indent if statements with two spaces' do
    @sass.each_line do |line|
      line.should =~ /^  @/ if line =~ /@(?:else|if)/
    end
  end

  it 'should indent position assigments with four spaces' do
    @sass.each_line do |line|
      line.should =~ /^    !pos/ if line =~ /@pos = -\d+px/
    end
  end

  it 'should indent background statements with two spaces' do
    @sass.each_line do |line|
      line.should =~ /  :background/ if line =~ /:background/
    end
  end

  it 'should include statements for all the icons' do
    @sass.should include('!icon == "one"')
    @sass.should include('!icon == "two"')
    @sass.should include('!icon == "three"')
  end

  it 'should use an `@if` statement for the first icon' do
    @sass.should include('@if !icon == "one"')
    @sass.should_not include('@if !icon == "two"')
    @sass.should_not include('@if !icon == "three"')
  end

  it 'should use an `@else if` statement for subsequence icons' do
    @sass.should_not include('@else if !icon == "one"')
    @sass.should include('@else if !icon == "two"')
    @sass.should include('@else if !icon == "three"')
  end

  it 'should use the given base directory when creating the sprite path' do
    @sass.should =~ %r{url\(/images/sprites}
  end

  it 'should use the generator name when creating the sprite path' do
    @sass.should include('mysprites.png')
  end
end

# RakeRunner =================================================================

##
# Copies the icons source files from fixture/public/images/sprites/src to
# the tmp/spec/sprites/src directory. Removes tmp/spec/sprites when done.
#
describe Kin::Sprites::RakeRunner do
  before(:each) do
    FileUtils.mkdir_p(tmp_path('sprites'))
    FileUtils.cp_r(fixture_path('public', 'images', 'sprites'), tmp_path)
  end

  after(:each) do
    FileUtils.rm_r(tmp_path('sprites'))
  end

  def rake_runner(sprites_yml = 'sprites.yml')
    Kin::Sprites::RakeRunner.new(
      fixture_path('config', sprites_yml),
      tmp_path('sprites'),
      tmp_path('sprites', '_sprites.sass'))
  end

  it 'should raise an error when sprites.yml could not be found' do
    lambda {
      Kin::Sprites::RakeRunner.new(
        'not_here.yml',
        fixture_path('public', 'images', 'sprites'),
        fixture_path('public', 'stylesheets', 'sass', '_sprites.sass')
      )
    }.should raise_error(Kin::Sprites::SpriteError)
  end

  describe 'when no sprites have been previously generated' do
    it 'should generate the sprite files' do
      out = capture_stdout { rake_runner.generate! }
      out.should =~ /Regenerated "general"/
      out.should =~ /Regenerated "more"/
    end

    it 'should generate the SASS partial' do
      out = capture_stdout { rake_runner.generate! }
      out.should =~ /Saved SASS/
    end
  end

  describe 'when the sprites have been previously generated,' do
    describe 'and one has changed' do
      before(:each) do
        capture_stdout { rake_runner.generate! }
      end

      it 'should regenerate the changed sprite file' do
        out = capture_stdout { rake_runner('sprites.different.yml').generate! }
        out.should =~ /Regenerated "general"/
      end

      it 'should not regenerate the unchanged sprite file' do
        out = capture_stdout { rake_runner('sprites.different.yml').generate! }
        out.should =~ /Ignoring "more"/
      end

      it 'should regenerate the SASS partial' do
        out = capture_stdout { rake_runner('sprites.different.yml').generate! }
        out.should =~ /Saved SASS/
      end
    end

    describe 'have not changed,' do
      before(:each) do
        capture_stdout { rake_runner.generate! }
      end

      describe 'and :force is false' do
        it 'should not regenerate the sprite files' do
          out = capture_stdout { rake_runner.generate! }
          out.should =~ /Ignoring "general"/
          out.should =~ /Ignoring "more"/
        end

        it 'should not regenerate the SASS partial' do
          out = capture_stdout { rake_runner.generate! }
          out.should_not =~ /Saved SASS/
        end
      end

      describe 'and :force is true' do
        it 'should regenerate the sprite files' do
          out = capture_stdout { rake_runner.generate!(true) }
          out.should =~ /Regenerated "general"/
          out.should =~ /Regenerated "more"/
        end

        it 'should regenerate the SASS partial' do
          out = capture_stdout { rake_runner.generate!(true) }
          out.should =~ /Saved SASS/
        end
      end

      describe 'and a sprite has been deleted' do
        before(:each) do
          FileUtils.rm(tmp_path('sprites', 'general.png'))
        end

        it 'should regenerate the deleted sprite' do
          out = capture_stdout { rake_runner.generate! }
          out.should =~ /Regenerated "general"/
        end

        it 'should not regenereate the unchanged sprite' do
          out = capture_stdout { rake_runner.generate! }
          out.should =~ /Ignoring "more"/
        end

        it 'should regenerate the SASS partial' do
          out = capture_stdout { rake_runner.generate!(true) }
          out.should =~ /Saved SASS/
        end
      end
    end
  end

end
