module Unlisp
  class Token < Struct.new(:type, :value)
    # Token types
    INTEGER  = 1
    # STRING   = 2
    ATOM     = 3
    LIST     = 4
    FUNCTION = 5
    ERROR    = 6

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
