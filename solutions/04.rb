module UI
  module Vertical
    def vertical_function(array, border)
      help = array.map { |item| first(item) }
      size = 0
      help.each { |item| size = second(item, size) }
      help = help.map { |item| third(item, border, size) }
      help.join
    end

    def first(item)
      if item.include? "\n"
  item.chop.split("\n")
      else
        [] << item
      end
    end

    def second(array, size)
      array.each do |item|
        size = helper(size, item)
      end
      size
    end

    def third(array, border, size)
      array = array.map do |item|
        border + item + (" " * (size - item.length)) + border + "\n"
      end
      array
    end

    def helper(size, item)
      size < item.length ? item.length : size
    end
  end

  module Help
    def function(array, size)
      array.size > size ? array.size : size
    end

    def checker(size, index)
      size != 1 || index != size - 1 ? "\n" : ""
    end

    def get_size(item, size)
      item.each { |element| size = helper(size, element) }
      size
    end

    def transform(item, size)
      item.map { |element| help(element, size) }
    end

    def help(item, size)
      item.length != size ? item + (" " * (size - item.length)) : item
    end

    def check(border, string)
      string << border if border != nil
    end
  end

  module Horizontal
    extend Vertical
    extend Help
    def self.horizontal_function(array, border)
      size = 0
      current = array.map { |item| first(item) }
      current.each { |item| size = function(item, size) }
      processing(current, size, border)
    end

    def self.processing(array, size, border)
      @current = array
      string, index = "", 0
      size.times do
  arrange(border, index, string)
  string ,index = string + checker(size, index), index + 1
      end
      string << "\n"
    end

    def self.arrange(border, index, string)
      check(border, string)
      primary(@current, index, string)
      check(border, string)
    end

    def self.primary(array, index, string)
      array.each do |item|
  size = 0
  size = get_size(item, size)
  item = transform(item, size)
  string << final(index, size, item)
      end
    end

    def self.final(index, size, item)
      if (item[index] == nil and (not (item[0].include? "\n")))
  " " * item[0].length
      elsif
  item[index] == nil then " " * size
      else
  item[index]
      end
    end
  end

  class TextScreen
    @main_array = []
    @array = []
    extend Vertical
    include Horizontal

    def self.label (text:, border: nil, style: nil)
      text = text.send(style) if style != nil
      if border != nil
        @main_array << (border + text + border)
      else
  @main_array << text
      end
      @main_array.join
    end

    def self.vertical(border: nil, style: nil)
      Proc.new.call
      @array << (@main_array.join("\n") << "\n") unless @main_array.empty?
      @main_array = []
      if border != nil then vertical_function(@array, border)
      else
        (@array.join("\n") << "\n").squeeze("\n")
      end
    end

    def self.horizontal(border: nil, style: nil)
      Proc.new.call
      @array << @main_array.join unless @main_array.empty?
      @main_array = []
      UI::Horizontal.horizontal_function(@array, border)
    end

    def self.draw
      @array = []
      TextScreen.instance_eval(&Proc.new)
    end
  end
end