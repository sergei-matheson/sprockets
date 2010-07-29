module Sprockets
  class Preprocessor
    attr_reader :environment, :concatenation, :source_files, :asset_paths, :packages
    
    def initialize(environment, options = {})
      @environment = environment
      @concatenation = Concatenation.new
      @source_files = []
      @asset_paths = []
      @packages = []
      @options = options
			@options[:escape_sequence] ||= "\a"
			@options[:quote_char] ||= "'"
			@haml_helper = HamlHelper.new @options[:escape_sequence], @options[:quote_char]
    end
    
    def require(source_file)
      return if source_files.include?(source_file)
      source_files << source_file
      
      source_file.each_source_line do |source_line|
        if source_line.require?
          require_from_source_line(source_line)
        elsif source_line.provide?
          provide_from_source_line(source_line)
        elsif source_line.import_haml?
          import_haml_from_source_line(source_line)
        elsif source_line.package?
          package_from_source_line(source_line)
        else
          record_source_line(source_line)
        end
      end
    end
    
    def provide(asset_path)
      return if !asset_path || asset_paths.include?(asset_path)
      asset_paths << asset_path
    end

    def import_haml(haml_path)
      return if !haml_path 
			haml_template = File.read haml_path
			engine = ::Haml::Engine.new(haml_template)
			"#{@options[:escape_sequence]}#{engine.render @haml_helper}#{@options[:escape_sequence]}".gsub(@options[:quote_char], "\\\\#{@options[:quote_char]}").gsub("#{@options[:escape_sequence]}", @options[:quote_char])
    end

		def create_package(package)
			return if @packages.include?(package)

			hierarchy = package.split('.');

			found_new = false
			current_var = ''
			json_object = nil
			json_pointer = nil
			is_global = true

			hierarchy.each do |element|
				if found_new
					if not json_object
						json_object = {}
						json_pointer = json_object
					end
					json_pointer[element.to_sym] = {}
					json_pointer = json_pointer[element.to_sym]
					packages << ( current_var ? "#{current_var}.#{element}" : element)
				else
					if current_var.length > 0
						current_var += '.'
						is_global = false
					end
					current_var += element
					if not @packages.include? current_var
						found_new = true
						packages << current_var
					end
				end
			end
			if found_new
				"#{is_global ? 'var ':''}#{current_var} = #{json_object.to_json};\n"
			end
		end
    
    protected
      attr_reader :options
    
      def require_from_source_line(source_line)
        require pathname_from(source_line).source_file
      end
      
      def provide_from_source_line(source_line)
        provide asset_path_from(source_line)
      end

      def import_haml_from_source_line(source_line)
				begin
					html_string  = import_haml source_line.import_haml[/^.(.*).$/, 1]
				rescue
					message = "Error at #{source_line.inspect}: Could not import haml from '#{source_line.import_haml}': #{$!.inspect}"
					raise message
				end
				if html_string 
					source_line.line= html_string
          concatenation.record(source_line)
				end
      end

      def package_from_source_line(source_line)
				package = create_package source_line.package[/^.(.*).$/, 1]
				if package 
					source_line.line= package
					concatenation.record(source_line)
				end
			end
      
      def record_source_line(source_line)
        unless source_line.comment? && strip_comments?
          concatenation.record(source_line)
        end
      end

      def strip_comments?
        options[:strip_comments] != false
      end
      
      def pathname_from(source_line)
        pathname = send(pathname_finder_from(source_line), source_line)
        raise_load_error_for(source_line) unless pathname
        pathname
      end

      def pathname_for_require_from(source_line)
        environment.find(location_from(source_line))
      end
      
      def pathname_for_relative_require_from(source_line)
        source_line.source_file.find(location_from(source_line))
      end

      def pathname_finder_from(source_line)
        "pathname_for_#{kind_of_require_from(source_line)}_from"
      end

      def kind_of_require_from(source_line)
        source_line.require[/^(.)/, 1] == '"' ? :relative_require : :require
      end

      def location_from(source_line)
        location = source_line.require[/^.(.*).$/, 1]
        File.join(File.dirname(location), File.basename(location, ".js") + ".js")
      end
      
      def asset_path_from(source_line)
        source_line.source_file.find(source_line.provide, :directory)
      end

      def raise_load_error_for(source_line)
        kind = kind_of_require_from(source_line).to_s.tr("_", " ")
        file = File.split(location_from(source_line)).last
        raise LoadError, "can't find file for #{kind} `#{file}' (#{source_line.inspect})"
      end
  end
end
