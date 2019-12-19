# lib/plan_stylesheet.rb

class PlanStylesheet
  def initialize(book)
    @book = book
  end

  def stylesheet_file
    filename = [
      @book.id,
      "custom"
    ].join('-')

    File.join \
      'companies',
      "#{filename}.css"
  end

  def sass_file_path
    Rails.root.join('app', 'assets', 'stylesheets', "#{self.stylesheet_file}.scss")
  end

  def styles
    BooksController.new.render_to_string 'books', formats: [:scss], layout:  false
  end

  def compiled?
    if Rails.application.config.assets.compile
      File.exists?(self.sass_file_path) && !File.zero?(self.sass_file_path)
    else
      Rails.application.config.assets.digests[self.stylesheet_file].present?
    end
  end

  #run time compile the file
  def compile
    File.open(self.sass_file_path, 'w') { |f| f.write(self.styles) }
    unless Rails.application.config.assets.compile
      env = Rails.application.assets.is_a?(Sprockets::Index) ? Rails.application.assets.instance_variable_get('@environment') : Rails.application.assets
      Sprockets::StaticCompiler.new(
        env,
        File.join(Rails.public_path, Rails.application.config.assets.prefix),
        [self.stylesheet_file],
        digest:   true,
        manifest: false
      ).compile
      Rails.application.config.assets.digests[self.stylesheet_file] = env[self.stylesheet_file].digest_path
    end

    # Delete old file
    Dir[self.sass_file_path.sub(/\d+.css.scss$/, '*')].each do |file|
      File.delete file unless file == self.sass_file_path.to_s
    end
  end
end
