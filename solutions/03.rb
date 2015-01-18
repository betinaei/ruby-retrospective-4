module RBFS
  class File
    attr_accessor :data

    def initialize(object = nil)
      @data = object
    end

    def data_type
      case @data.class.to_s
        when 'String' then :string
        when 'NilClass' then :nil
        when 'Symbol' then :symbol
        when 'Fixnum' then :number
        when 'Float' then :number
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
        when 'number' then parse_helper(data)
        else
          parse_helper1(data)
      end
    end

    def parse_helper(data)
      if data.include? '.'
        File.new data.to_f
      else
        File.new data.to_i end
    end

    def parse_helper1(data)
      if data == 'true'
        File.new true
      else
        File.new false
      end
    end
  end


  class Directory
    def initialize
      @directory = []
    end

    def add_file(name, file)
      @directory << [name, file]
    end

    def add_directory(name, directory = Directory.new)
      @directory << [name, directory]
    end

    def [](name)
      help = []
      help = @directory.select { | (first, second) | first == name }
      case help.size
        when 1 then help.flatten.last
        when 2 then Helper.getter(help)
        else
          nil
      end
    end

    def files
      hash = {}
      data = @directory.select { | (first, last) | last.instance_of? File }
      data.each do | (first, last) |
        hash[first] = last
      end
      hash
    end

    def directories
      hash = {}
      data = @directory.select { | (first, last) | (last.is_a? Directory or last == []) }
      data.each do | (first, last) |
        hash[first] = last
      end
      hash
    end

    def serialize
      result = ""
      if files.empty? & directories.empty?
        result += "0:0:"
      else
        result = Helper.serializing(result, files, directories)
      end
      result
    end

    def self.parse(string_data)
      directory = Directory.new
      if string_data != '0:0:'
        array = string_data.partition(':')
        string_data = Helper.parsing(array, string_data, directory)
        Helper.parsing_function(array, string_data, directory)
      end
      directory
    end
  end

  class Helper
    class << self
      def parsing(array, string_data, directory)
        string_data = array.last
        array.first.to_i.times do
        string_data = self.function(array, string_data, directory)
        end
        string_data
     end

      def function(array, string_data, directory)
        array = string_data.partition(':')
        file_name = array.first
        array = array.last.partition(":")
        count = array.first.to_i
        directory.add_file(file_name, File.parse(array.last.slice(0, count)))
        array = array.last.partition(":")
        string_data = array.last.slice(count - array.first.size - 1, array.last.size)
        string_data
      end

      def parsing_function(array, string_data, directory)
        array = string_data.partition(":")
        array.first.to_i.times do
          array = array.last.partition(":")
          name = array.first
          array = array.last.partition(":")
          limit = array.first.to_i
          directory.add_directory(name, Directory.parse(array.last.slice(0, limit)))
        end
      end

      def serializing(result, keys, data)
        result = result + (keys.size.to_s + ':')
        result, count = self.helper(result, keys.size, keys) + (data.size.to_s + ':'), 0
        while(count < data.size)
          data.values[count] = self.checker(data.values[count])
          first, last = data.keys[count], data.values[count]
          result += (first.to_s + ':' + last.serialize.length.to_s + ':' + last.serialize)
          count += 1
        end
        result
      end

      def helper(result, size, hash)
        count = 0
        while (count < size)
          key, value = hash.keys[count], hash.values[count]
          result += (key.to_s + ':' + value.serialize.length.to_s + ':' + value.serialize)
          count += 1
        end
        result
      end

      def checker(directory)
        if (directory.files.empty? and directory.files.empty?)
          directory = Directory.new
        end
        directory
      end

      def getter(help)
        help.select{ | (first, second) | second.instance_of? Directory }.flatten.last
      end
    end
  end
end