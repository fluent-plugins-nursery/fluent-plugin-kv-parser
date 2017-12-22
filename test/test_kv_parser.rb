require 'fluent/test'
require 'fluent/parser'
require 'fluent/plugin/parser_kv'

class KVParserTest < ::Test::Unit::TestCase
  include ParserTest

  def test_basic
    parser = Fluent::TextParser::KVParser.new
    parser.configure
    parser.parse("k1=v1 k2=v2") {|_, v| assert_equal({"k1"=>"v1", "k2"=>"v2"}, v)}
    parser.parse("k1=v1    k2=v2") {|_, v| assert_equal({"k1"=>"v1", "k2"=>"v2"}, v)}
    parser.parse("k2=v2 k1=v1") {|_, v| assert_equal({"k1"=>"v1", "k2"=>"v2"}, v)}
    parser.parse("k2=v2\tk1=v1") {|_, v| assert_equal({"k1"=>"v1", "k2"=>"v2"}, v)}
    parser.parse("k2=v2\t k1=v1") {|_, v| assert_equal({"k1"=>"v1", "k2"=>"v2"}, v)}
  end

  def test_with_types
    parser = Fluent::TextParser::KVParser.new
    parser.configure("types" => "k1:integer")
    parser.parse("k1=100") {|_, v| assert_equal(100, v["k1"])}
  end

  def test_with_time
    parser = Fluent::TextParser::KVParser.new
    parser.configure("types" => "time:time")
    parser.parse("k1=foo time=1970-01-01T01:00:00") {|time, v|
      assert_equal(3600, time)
      assert_equal("foo", v["k1"])
    }
  end

  def test_with_custom_time_key
    parser = Fluent::TextParser::KVParser.new
    parser.configure("time_key" => "my_time", "types" => "my_time:time")
    parser.parse("k1=foo my_time=1970-01-01T01:00:00") {|time, v|
      assert_equal(3600, time)
      assert_equal("foo", v["k1"])
    }
  end

  def test_custom_delimiter
    parser = Fluent::TextParser::KVParser.new
    parser.configure("kv_delimiter" => "|")
    parser.parse("k1=v1|k2=v2") {|_, v| assert_equal({"k1"=>"v1", "k2"=>"v2"}, v)}
    parser.configure("kv_delimiter" => "/[@ ]/")
    parser.parse("k1=v1@k2=v2 k3=v3") {|_, v|
      assert_equal({"k1"=>"v1", "k2"=>"v2", "k3"=>"v3"}, v)
    }
  end

  def test_custom_kv_char
    parser = Fluent::TextParser::KVParser.new
    parser.configure("kv_char" => "#")
    parser.parse("k1#v1 k2#v2") {|_, v| assert_equal({"k1"=>"v1", "k2"=>"v2"}, v)}
  end

  def test_types_param
    parser = Fluent::TextParser::KVParser.new
  end
end
