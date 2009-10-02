require "test_helper"

class ConcatenationTest < Test::Unit::TestCase
  def setup
    @concatenation = Sprockets::Concatenation.new
    @environment = environment_for_fixtures
  end
  
  def test_record
    assert_equal [], @concatenation.source_lines
    assert_equal "hello\n", @concatenation.record(source_line("hello\n")).to_s
    assert_equal "world\n", @concatenation.record(source_line("world\n")).to_s
    assert_equal ["hello\n", "world\n"], @concatenation.source_lines.map { |source_line| source_line.to_s }
  end
  
  def test_to_s
    @concatenation.record(source_line("hello\n"))
    @concatenation.record(source_line("world\n"))
    assert_equal "hello\nworld\n", @concatenation.to_s
  end
  
  def test_to_s_with_yui_compressor_true
    return unless yui_compressor_available?
    @concatenation = Sprockets::Concatenation.new(:yui_compressor => true)
    source_file("src/simple_script.js").each_source_line { |l| @concatenation.record(l) }
    assert_equal content_of_fixture("src/simple_script_compressed.js"), @concatenation.to_s
  end
  
  def test_to_s_with_yui_compressor_shortening_variable_names
    return unless yui_compressor_available?
    @concatenation = Sprockets::Concatenation.new(:yui_compressor => { :munge => true })
    source_file("src/simple_script.js").each_source_line { |l| @concatenation.record(l) }
    assert_equal content_of_fixture("src/simple_script_compressed_shortened.js"), @concatenation.to_s
  end
  
  def test_save_to
    filename = File.join(FIXTURES_PATH, "output.js")
    @concatenation.save_to(filename)
    assert_equal @concatenation.to_s, IO.read(filename)
    File.unlink(filename)
  end
end
