require "fluent/plugin/parser"

module Fluent
  module Plugin
    class KVParser < Fluent::Plugin::Parser
      Fluent::Plugin.register_plugin("kv", self)

      config_param :kv_delimiter, :string, default: '/[\t\s]+/'
      config_param :kv_char, :string, default: '='

      config_set_default :time_key, "time"

      def configure(conf)
        super
        if @kv_delimiter[0] == '/' and @kv_delimiter[-1] == '/'
          @kv_delimiter = Regexp.new(@kv_delimiter[1..-2])
        end
      end

      def parse(text)
        record = {}
        text.split(@kv_delimiter).each do |kv|
          key, value = kv.split(@kv_char, 2)
          record[key] = value
        end

        time = parse_time(record)
        time, record = convert_values(time, record)

        yield time, record
      end
    end
  end
end
