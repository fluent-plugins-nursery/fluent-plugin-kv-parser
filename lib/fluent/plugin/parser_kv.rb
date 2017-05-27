module Fluent
  class TextParser
    class KVParser < Parser
      include Configurable
      include TypeConverter

      config_param :kv_delimiter, :string, :default => '\t\s'
      config_param :kv_char, :string, :default => '='
      config_param :time_key, :string, :default => 'time'

      def configure(conf={})
        super
        if @kv_delimiter[0] == '/' and @kv_delimiter[-1] == '/'
          @kv_delimiter = Regexp.new(@kv_delimiter[1..-2])
        end

        @kv_regex_str = '("(?:(?:\\\.|[^"])*)"|(?:[^' + @kv_delimiter + ']*))\s*' + @kv_char + '\s*("(?:(?:\\\.|[^"])*)"|(?:[^' + @kv_delimiter + ']*))'
        @kv_regex = Regexp.new(@kv_regex_str)
      end

      def parse(text)
        record = {}

        text.scan(@kv_regex) do | m |
          k = (m[0][0] == '"' and m[0][-1] == '"') ? m[0][1..-2] : m[0]
          v = (m[1][0] == '"' and m[1][-1] == '"') ? m[1][1..-2] : m[1]
          record[k] = v
        end

        convert_field_type!(record) if @type_converters
        time = record.delete(@time_key)
        if time.nil?
          time = Engine.now
        elsif time.respond_to?(:to_i)
          time = time.to_i
        else
          raise RuntimeError, "The #{@time_key}=#{time} is a bad time field"
        end

        yield time, record
      end

      private

      def convert_field_type!(record)
        @type_converters.each_key { |key|
          if value = record[key]
            record[key] = convert_type(key, value)
          end
        }
      end

    end
    register_template('kv', Proc.new { KVParser.new })
  end
end