module RBFS
  class File
    attr_accessor :data

    def initialize(object = nil)
      @data = object
    end

    def data_type
      case @data
        when String then :string
        when NilClass then :nil
        when Symbol then :symbol
        when Fixnum, Float then :number
        else :boolean
      end
    end

    def serialize
      format("%s:%s", data_type.to_s, @data.to_s)
    end

    def self.parse(string_data)
      data = string_data.partition(":").last
      case string_data.partition(":").first
        when 'nil' then File.new nil
        when 'string' then File.new data
        when 'symbol' then File.new data.to_sym
        when 'number' then File.new data.to_f
        else  File.new true
      end
    end
  end

  class Directory
    def initialize
      @directories = {}
      @files = {}
    end

    def add_file(name, file)
      @directory[name] = file
    end

    def add_directory(name, directory = Directory.new)
      @directory[name] = directory
    end

    def [](name)
      if ! @directories[name]
        @files[name]
      else
        @directories[name]
      end
    end

    def serialize
      result = "#{@files.count}:"
      @files.each do |name, file|
        result += "#{name}:#{file.serialize.length}:#{file.serialize}"
      end
      result += "#{@directories.count}:"
      @directories.each do |name, directory|
        serialized = directory.serialize
        result += "#{name}:#{serialized.length}:#{serialized}"
      end
      result
    end

    def self.parse(string_data)
      directory = Directory.new
      string_data = parser(string_data) do |name, str|
        directory.add_file name, File.parse(str)
      end
      string_data = parser(string_data) do |name, str|
        directory.add_directory name, Directory.parse(str)
      end
      directory
    end

    def parser(string_data, &block)
      n, string_data = string_data.split(':', 2)
      n.to_i.times do
        name, size, left = string_data.split(':', 3)
        block.call name, left[0...size.to_i]
        string_data = left[size.to_i..(-1)]
      end
      string_data
    end
  end
end