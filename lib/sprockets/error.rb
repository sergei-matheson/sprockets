module Sprockets
  class Error < ::StandardError;        end
  class LoadError < Error;              end
  class UndefinedConstantError < Error; end
  class ConfigurationError     < Error; end
end
