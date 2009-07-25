module Sprockets
  module Directives
    class ProvideDirective < Directive
      def self.pattern
        /(provide)\s+(#{QUOTED_STRING})/
      end
      
      def evaluate_in(preprocessor)
        if asset_path
          preprocessor.provide(asset_path)
        else
          raise_load_error
        end
      end

      def asset_path
        source_file.find(provide_location, :directory)
      end
      
      def provide_location
        parse_quoted_string(argument)
      end
    end
  end
end
