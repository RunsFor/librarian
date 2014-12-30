require 'digest'

class Librarian
  attr_reader :path

  def initialize(path = './')
    @path = path
  end

  def search(query = '')
    all.select { |book| File.basename(book).match(query) }
  end

  # Available types: [ :sha1, :sha2, :md5, :filename ]
  # @return Hash
  def dublicates(type: :filename)
    group_by(type, all).select { |_, books| books.size > 1 }
  end

  def all
    supported_formats = %i(doc pdf mobi epub djvu txt fb2)
    file_pattern = "*.{#{supported_formats.join(',')}}"
    lookup_path = File.join(path, '**', file_pattern)

    Dir.glob(lookup_path).select{ |path| File.file?(path) }
  end

  private

  def group_by(type, books)
    books.inject({}) do |collector, book|
      case type
      when :filename
        key = File.basename(book)
      when :md5
        key = Digest::MD5.hexdigest(File.read(book))
      when :sha1
        key = Digest::SHA1.hexdigest(File.read(book))
      when :sha2
        key = Digest::SHA2.hexdigest(File.read(book))
      else
        raise 'Wrong grouping type'
      end

      if collector.has_key?(key)
        collector[key].push(book)
      else
        collector[key] = [book]
      end

      collector
    end
  end
end

