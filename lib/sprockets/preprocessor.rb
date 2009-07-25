module Sprockets
  class Preprocessor
    attr_reader :environment, :concatenation, :source_files, :pdoc_lines, :asset_paths
    
    def initialize(environment, options = {})
      @environment   = environment
      @concatenation = Concatenation.new
      @source_files  = []
      @comment_lines = []
      @pdoc_lines    = []
      @asset_paths   = []
      @options       = options
    end
    
    def require(source_file)
      return if source_files.include?(source_file)
      source_files << source_file
      
      source_file.each_line do |line, number|
        process(source_file, line, number)
      end
    end
    
    def provide(asset_path)
      return if !asset_path || asset_paths.include?(asset_path)
      asset_paths << asset_path
    end
    
    protected
      attr_reader :options, :comment_lines

      def process(source_file, line, number)
        if inside_multi_line_comment?
          comment_lines.push([source_file, line, number])

          if line_closes_multi_line_pdoc_comment?(line)
            record_comment_lines_as(:pdoc)
          elsif line_closes_multi_line_comment?(line)
            record_comment_lines_as(:source)
          end

        elsif line_opens_multi_line_pdoc_comment?(line)
          comment_lines.push([source_file, line, number])

        elsif line_is_single_line_comment?(line)
          record_single_comment_line(source_file, line, number)

        else
          record_source_line(source_file, line, number)
        end
        
      rescue UndefinedConstantError => constant
        raise UndefinedConstantError, 
          "couldn't find constant `#{constant}' in line #{number} of #{source_file.pathname}"
      end

    private
      def record_source_line(source_file, line, number)
        concatenation.record(source_file, format(line), number)
      end
      
      def record_pdoc_line(source_file, line, number)
        pdoc_lines.push([source_file, line, number])
        record_source_line(source_file, line, number) unless stripping_comments?
      end

      def record_single_comment_line(source_file, line, number)
        record_source_line(source_file, line, number) unless stripping_comments?
      end

      def record_comment_lines_as(kind)
        comment_lines.each do |comment_line|
          send(:"record_#{kind}_line", *comment_line)
        end
        comment_lines.clear
      end
      
      def format(line)
        result = line.chomp
        interpolate_constants!(result, environment.constants)
        strip_trailing_whitespace!(result)
        result << $/
      end
      
      def interpolate_constants!(result, constants)
        result.gsub!(/<%=(.*?)%>/) do
          constant = $1.strip
          if value = constants[constant]
            value
          else
            raise UndefinedConstantError, constant
          end
        end
      end
      
      def strip_trailing_whitespace!(result)
        result.gsub!(/\s+$/, "")
      end

      def inside_multi_line_comment?
        comment_lines.any?
      end
      
      def line_opens_multi_line_pdoc_comment?(line)
        if rest = line[/^\s*\/\*\*(.*)/, 1]
          !line_closes_multi_line_comment?(rest)
        end
      end
      
      def line_closes_multi_line_pdoc_comment?(line)
        line =~ /\*\*\/\s*$/
      end
      
      def line_opens_multi_line_comment?(line)
        if rest = line[/^\s*\/\*(.*)/, 1]
          !line_closes_multi_line_comment?(rest)
        end
      end
      
      def line_closes_multi_line_comment?(line)
        if rest = line[/\*\/(.*)/, 1]
          !line_opens_multi_line_comment?(rest)
        end
      end
      
      def line_is_single_line_comment?(line)
        line =~ /^\s*\/\//
      end
      
      def stripping_comments?
       options[:strip_comments] != false
      end
  end
end
