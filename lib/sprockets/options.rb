module Sprockets
  module Options
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def options
        @options ||= {}
      end
    
      def option(name, kind)
        options[name] = kind
        ruby_name = name.inspect
        
        class_eval <<-EOS, __FILE__, __LINE__ + 1
          def #{name}
            options[#{ruby_name}]
          end
        
          def #{name}=(value)
            options[#{ruby_name}] = self.class.parse_value(#{ruby_name}, value)
          end
        EOS
      end
      
      def option_names
        options.keys
      end

      def parse_value(name, value)
        send("parse_#{options[name]}_value", value)
      end
      
      protected
        if Sprockets.running_on_windows?
          COLLECTION_SEPARATOR = ";"
        else
          COLLECTION_SEPARATOR = ":"
        end
      
        def parse_string_value(value)
          value.to_s unless value.nil?
        end
        
        def parse_collection_value(value)
          case value
          when Array
            value.map { |v| parse_string_value(v) }
          when String
            parse_collection_value(value.split(COLLECTION_SEPARATOR))
          end
        end
        
        def parse_boolean_value(value)
          case value.to_s.strip[0, 1]
          when "t", "1"
            true
          when "f", "0"
            false
          else
            nil
          end
        end
    end
  end
end
