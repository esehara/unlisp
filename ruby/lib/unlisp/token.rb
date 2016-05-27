module Unlisp
  class Token
    attr_accessor :type, :value, :env

    # Token types
    INTEGER  = 1
    # STRING   = 2
    ATOM     = 3
    LIST     = 4
    FUNCTION = 5
    ERROR    = 6

    def env! env
      @env = env
    end

    def self.false
      Token.new(INTEGER, 0)
    end

    def self.true
      Token.new(INTEGER, 1)
    end

    def false?
      integer? && value == 0
    end

    def true?
      integer? && value == 1
    end

    def initialize(type, value)
      @type = type
      @value = value
    end

    def print
      if list?
        value.map {|x| x.value}.to_s
      else
        value
      end
    end

    def integer?
      type == INTEGER
    end

    def function?
      type == FUNCTION
    end

    def list?
      type == LIST
    end

    def atom?
      type == ATOM
    end

    def to_s
      t = case type
          when LIST
            "List"
          when INTEGER
            "Integer"
          when FUNCTION
            "Function"
          end
      "- #{t}: #{value}"
    end

    def inspect
      to_s
    end
  end
end
