require "test_helper"

class ConfigurationTest < Test::Unit::TestCase
  def test_configuration_can_be_loaded_from_a_hash
    configuration = Sprockets::Configuration.new(:load_path => ["a", "b"], :root => ".")
    assert_equal({ :load_path => ["a", "b"], :root => "." }, configuration.to_hash)
  end
  
  def test_configuration_can_be_loaded_from_a_file
    configuration = Sprockets::Configuration.load_from_file(fixture("config/sprockets.yml"))
    assert_equal [], [:load_path, :source_files, :output_file] - configuration.to_hash.keys
    assert_equal %w( javascripts vendor/sprockets/*/src ), configuration.load_path
    assert_equal %w( javascripts/application.js javascripts/**/*.js ), configuration.source_files
    assert_equal "public/sprockets.js", configuration.output_file
  end
  
  def test_configuration_can_be_loaded_from_environment_variables
    environment = { 
      "sprockets_root"         => ".", 
      "sprockets_load_path"    => platform_path("javascripts", "vendor/sprockets/*/src"),
      "sprockets_expand_paths" => "true"
    }
    configuration = Sprockets::Configuration.load_from_environment(environment)
    assert_equal [], [:root, :load_path, :expand_paths] - configuration.to_hash.keys
    assert_equal ".", configuration.root
    assert_equal %w( javascripts vendor/sprockets/*/src ), configuration.load_path
    assert_equal true, configuration.expand_paths
  end

  def test_configuration_can_be_merged_into_another_configuration
    configuration_from_file = Sprockets::Configuration.load_from_file(fixture("config/sprockets.yml"))
    configuration_from_hash = Sprockets::Configuration.new(:load_path => "src", :root => ".")
    configuration_from_file.merge!(configuration_from_hash)

    assert_equal [], [:load_path, :source_files, :output_file, :root] - configuration_from_file.to_hash.keys
    assert_equal %w( src ), configuration_from_file.load_path
    assert_equal %w( javascripts/application.js javascripts/**/*.js ), configuration_from_file.source_files
    assert_equal "public/sprockets.js", configuration_from_file.output_file
    assert_equal ".", configuration_from_file.root
  end
  
  protected
    def platform_path(*locations)
      locations.join(Sprockets::Options::ClassMethods::COLLECTION_SEPARATOR)
    end
end