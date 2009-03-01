module Sprockets
  class Configuration
    include Options

    option :root,                 :string
    option :asset_root,           :string
    option :output_file,          :string
    option :load_path,            :collection
    option :source_files,         :collection
    option :expand_paths,         :boolean
    option :generate_output_file, :boolean
    
    class << self
      def load_from_file(filename = find_configuration_file)
        raise Sprockets::ConfigurationError, "configuration file not found" unless filename
        new(YAML.load(IO.read(filename)))
      end
    
      def load_from_environment(env = ENV)
        new(extract_environment_options_from(env))
      end
      
      def find_configuration_file
        search_upwards_for("config/sprockets.yml")
      end

      protected
        def search_upwards_for(filename)
          pwd = original_pwd = Dir.pwd
          loop do
            return File.expand_path(filename) if File.file?(filename)
            Dir.chdir("..")
            return nil if Dir.pwd == pwd
            pwd = Dir.pwd
          end
        ensure
          Dir.chdir(original_pwd)
        end

        def extract_environment_options_from(env)
          env.inject({}) do |options, (key, value)|
            if name = key[/^(?:REDIRECT_)?sprockets_(.+)/, 1]
              options[name] = value
            end
            options
          end
        end
    end
    
    attr_reader  :options
    alias_method :to_hash, :options
    
    def initialize(options = {})
      @options = {}
      merge!(options)
    end
    
    def merge!(options)
      options.to_hash.each do |key, value|
        send("#{key}=", value) if respond_to?("#{key}=")
      end
      self
    end
  end
end
