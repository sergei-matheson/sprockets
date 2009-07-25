module Sprockets
  module Directives
    class RequireDirective < Directive
      def self.pattern
        /(require)\s+(#{ANGLED_STRING})/
      end
      
      def evaluate_in(preprocessor)
        if source_file_path
          preprocessor.require(source_file_path.source_file)
        else
          raise_load_error
        end
      end
      
      def source_file_path
        @source_file_path ||= location_finder.find(normalize(require_location))
      end
      
      def require_location
        parse_angled_string(argument)
      end

      protected
        def location_finder
          environment
        end
        
        def normalize(location)
          File.join(File.dirname(location), File.basename(location, ".js") + ".js")
        end
    end
  end
end
