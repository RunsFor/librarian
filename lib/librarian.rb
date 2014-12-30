class Librarian
  attr_reader :path

  def initialize(path = './')
    @path = path
  end

  def search(query = '')
    all.select { |book| File.basename(book).match(query) }
  end

  def dublicates
    grouped_by_filename = all.inject({}) do |collector, book|
      name = File.basename(book)

      if collector.has_key?(name)
        collector[name].push(book)
      else
        collector[name] = [book]
      end

      collector
    end

    grouped_by_filename.select { |_, books| books.size > 1 }
  end

  def all
    supported_formats = %i(doc pdf mobi epub djvu txt fb2)
    file_pattern = "*.{#{supported_formats.join(',')}}"
    lookup_path = File.join(path, '**', file_pattern)

    Dir.glob(lookup_path)
  end
end

