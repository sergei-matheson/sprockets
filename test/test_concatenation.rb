require "test_helper"

class ConcatenationTest < Test::Unit::TestCase
  def setup
    @concatenation = Sprockets::Concatenation.new
    @environment = environment_for_fixtures
  end
  
  def test_record
    assert_equal [], @concatenation.lines
    assert_equal "hello\n", @concatenation.record(source_file, "hello\n", 1).to_s
    assert_equal "world\n", @concatenation.record(source_file, "world\n", 2).to_s
    assert_equal ["hello\n", "world\n"], @concatenation.lines
  end
  
  def test_to_s
    @concatenation.record(source_file, "hello\n", 1)
    @concatenation.record(source_file, "world\n", 2)
    assert_equal "hello\nworld\n", @concatenation.to_s
  end
  
  def test_save_to
    filename = File.join(FIXTURES_PATH, "output.js")
    @concatenation.save_to(filename)
    assert_equal @concatenation.to_s, IO.read(filename)
    File.unlink(filename)
  end
end
