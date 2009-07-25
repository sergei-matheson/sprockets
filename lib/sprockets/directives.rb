module Sprockets
  module Directives
    def self.find(line)
      directives.find do |directive_klass|
        directive_klass.parse(line)
      end
    end

    def self.directives
      constants.grep(/Directive$/).map do |directive_name|
        const_get(directive_name)
      end
    end
  end
end
