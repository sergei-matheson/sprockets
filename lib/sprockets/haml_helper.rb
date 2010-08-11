module Sprockets
	class HamlHelper
		def initialize escape_sequence, quote_char
			@escape_sequence = escape_sequence
			@quote_char = quote_char
		end

		def js js_string
			"#{@escape_sequence}+#{js_string.gsub(@quote_char, @escape_sequence)}+#{@escape_sequence}"
		end
	end
end
