require 'fluent/test'
require 'fluent/parser'
require 'fluent/plugin/parser_kv'

class KVParserTest < ::Test::Unit::TestCase

  def create_driver(conf = {})
    Fluent::Test::ParserTestDriver.new(Fluent::TextParser::KVParser).configure(conf)
  end

  def setup
    @timezone = ENV["TZ"]
    ENV["TZ"] = "UTC"
  end

  def teardown
    ENV["TZ"] = @timezone
  end

  def test_basic
    d = create_driver
    parser = d.instance
    parser.parse("k1=v1 k2=v2") {|_, v| assert_equal({"k1"=>"v1", "k2"=>"v2"}, v)}
    parser.parse("k1=v1    k2=v2") {|_, v| assert_equal({"k1"=>"v1", "k2"=>"v2"}, v)}
    parser.parse("k2=v2 k1=v1") {|_, v| assert_equal({"k1"=>"v1", "k2"=>"v2"}, v)}
    parser.parse("k2=v2\tk1=v1") {|_, v| assert_equal({"k1"=>"v1", "k2"=>"v2"}, v)}
    parser.parse("k2=v2\t k1=v1") {|_, v| assert_equal({"k1"=>"v1", "k2"=>"v2"}, v)}
  end

  def test_with_types
    d = create_driver("types" => "k1:integer")
    parser = d.instance
    parser.parse("k1=100") {|_, v| assert_equal(100, v["k1"])}
  end

  def test_with_time
    d = create_driver("types" => "time:time")
    parser = d.instance
    parser.parse("k1=foo time=1970-01-01T01:00:00") {|time, v|
      assert_equal(3600, time)
      assert_equal("foo", v["k1"])
    }
  end

  def test_with_custom_time_key
    d = create_driver("time_key" => "my_time", "types" => "my_time:time")
    parser = d.instance
    parser.parse("k1=foo my_time=1970-01-01T01:00:00") {|time, v|
      assert_equal(3600, time)
      assert_equal("foo", v["k1"])
    }
  end

  def test_custom_delimiter
    d = create_driver("kv_delimiter" => "|")
    parser = d.instance
    parser.parse("k1=v1|k2=v2") {|_, v| assert_equal({"k1"=>"v1", "k2"=>"v2"}, v)}
  end

  def test_custom_delimiter2
    d = create_driver("kv_delimiter" => "/[@ ]/")
    parser = d.instance
    parser.parse("k1=v1@k2=v2 k3=v3") {|_, v|
      assert_equal({"k1"=>"v1", "k2"=>"v2", "k3"=>"v3"}, v)
    }
  end

  def test_custom_kv_char
    d = create_driver("kv_char" => "#")
    parser = d.instance
    parser.parse("k1#v1 k2#v2") {|_, v| assert_equal({"k1"=>"v1", "k2"=>"v2"}, v)}
  end
end
