module Sprockets
  module Winnowers
    class Boolean

      def initialize(value)
        @value = value
      end 

      def should_record(source_line)
        @value
      end

      def self.true
        @@true
      end

      def self.false
        @@false
      end

      @@true = Boolean.new(true)
      @@false = Boolean.new(false)

    end

    class IsComment
      def should_record(source_line)
        not source_line.comment?
      end
    end

  end
end
