require 'fluent/test'
require 'fluent/test/driver/parser'
require 'fluent/plugin/parser_kv'

class KVParserTest < ::Test::Unit::TestCase
  def setup
    Fluent::Test.setup
  end

  def create_driver(conf={})
    Fluent::Test::Driver::Parser.new(Fluent::Plugin::KVParser).configure(conf)
  end

  data("single space" => ["k1=v1 k2=v2", { "k1" => "v1", "k2" => "v2" }],
       "multiple space" => ["k1=v1    k2=v2", { "k1" => "v1", "k2" => "v2" }],
       "reverse" => ["k2=v2 k1=v1", { "k1" => "v1", "k2" => "v2" }],
       "tab" => ["k2=v2\tk1=v1", { "k1" => "v1", "k2" => "v2" }],
       "tab and space" => ["k2=v2\t k1=v1", { "k1" => "v1", "k2" => "v2" }])
  test "parse" do |(text, expected)|
    d = create_driver
    d.instance.parse(text) do |_time, record|
      assert_equal(expected, record)
    end
  end

  test "parse with types" do
    d = create_driver("types" => "k1:integer")
    d.instance.parse("k1=100") do |_time, record|
      assert_equal({ "k1" => 100 }, record)
    end
  end

  test "parse with time" do
    d = create_driver("types" => "time:time")
    d.instance.parse("k1=foo time=1970-01-01T01:00:00") do |time, reocrd|
      assert_equal(3600, time)
      assert_equal({ "k1" => "foo" }, record)
    end
  end

  test "parse with custom time_key" do
    d = create_driver("time_key" => "my_time", "types" => "my_time:time")
    d.instance.parse("k1=foo my_time=1970-01-01T01:00:00") do |time, record|
      assert_equal(3600, time)
      assert_equal({ "k1" => "foo" }, record)
    end
  end

  data("pipe" => ["|", "k1=v1|k2=v2", {"k1" => "v1", "k2" => "v2" }],
       "regexp" => ["/[@ ]/", "k1=v1@k2=v2 k3=v3", { "k1" => "v1", "k2" => "v2", "k3" => "v3" }])
  test "parse with custom kv_delimiter" do |(delimiter, text, expected)|
    d = create_driver("kv_delimiter" => delimiter)
    d.instance.parse(text) do |_time, record|
      assert_equal(expected, record)
    end
  end

  test "parse with custom kv_char" do
    d = create_driver("kv_char" => "#")
    d.instance.parse("k1#v1 k2#v2") do |_time, record|
      assert_equal({ "k1" => "v1", "k2" => "v2" }, record)
    end
  end
end
