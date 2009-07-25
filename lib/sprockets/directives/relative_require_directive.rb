module Sprockets
  module Directives
    class RelativeRequireDirective < RequireDirective
      def self.pattern
        /(require)\s+(#{QUOTED_STRING})/
      end
      
      def require_location
        parse_quoted_string(argument)
      end

      protected
        def location_finder
          source_file
        end
    end
  end
end
