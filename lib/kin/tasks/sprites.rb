namespace :kin do

  desc "Regenerates the sprite images. Any sprites which haven't been " \
       "changed won't be regenerated."

  task 'sprites' do
    generate_sprites!(false)
  end

  desc "Regenerates the sprite images, even those which have not been " \
       "changed."

  task 'sprites:force' do
    generate_sprites!(true)
  end

  ##
  # Generates the sprites for the current Merb application.
  #
  # @param [Boolean] force
  #   Defines whether to regenerate sprites which haven't been changed.
  #
  def generate_sprites!(force)
    require 'kin/sprites'
    require 'kin/sprites/rake_runner'

    Kin::Sprites::RakeRunner.new(
      File.join(Merb.dir_for(:config), 'sprites.yml'),
      File.join(Merb.dir_for(:image), 'sprites'),
      File.join(Merb.dir_for(:stylesheet), 'sass', '_sprites.sass')
    ).generate!(force)
  end

end
