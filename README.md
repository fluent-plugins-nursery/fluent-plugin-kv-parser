# Key-Value Pairs Parser Plugin for [Fluentd](https://github.com/fluent/fluentd)

<img src="https://travis-ci.org/kiyoto/fluent-plugin-kv-parser.svg?branch=master"/>

## Overview

This is a parser plugin for Fluentd. Learn more about parser plugins [here](https://docs.fluentd.org/articles/parser-plugin-overview).

This plugin allows you to parse inputs that look like key-value pairs. For example, if your text logs look like

```
"this_field=10000  that_field=hello time=2013-01-01T12:34:00"
```

It is parsed as

```json
{"this_field":10000, "that_field":"hello"}
```

with the event's time being `2013-01-01T12:34:00`

## How to Install and Use

For Fluentd,

```
gem install fluent-plugin-kv-parser
```

For [Treasure Agent](https://docs.treasuredata.com/articles/td-agent),

```
/usr/sbin/td-agent-gem install fluent-plugin-kv-parser
```

Then, for parser-plugin enabled input plugins (including [in_tail](https://docs.fluentd.org/articles/in_tail), [in_tcp](https://docs.fluentd.org/articles/in_tcp), [in_udp](https://docs.fluentd.org/articles/in_udp) and [in_syslog](https://docs.fluentd.org/articles/syslog)), you can just write `format kv`

For example, using `in_tcp` with the following configuration:

```aconf
<source>
  type tcp
  port 24225
  tag kv_log
  format kv
  time_key my_time
  types k1:integer,my_time:time
</source>
<match kv_log>
  type stdout
</match>
```

Running

```shell
echo 'my_time=2014-12-31T00:00:00 k1=1234 k2=hello' | nc localhost 24224
```

gives

```shell
2014-12-31 00:00:00 +0000 kv_log: {"k1":1234,"k2":"hello"}
```

## Parameters

* **kv_delimiter**: The delimiter for key-value pairs. By default `\t\s` (one or more whitespace/tabs).
    
    - `kv_delimiter a` splits on one or more "a"s
    - `kv_delimiter ab` splits on one or more "a"s or "b"s

* **kv_char**: The string to split the key from the value. By default, it is "=".
* **time_key**: The time key field among the key-value pairs to be used as the time for the event. If missing or unparsable, the current time is used.
* **types**: The parameter to convert the values of key-value pairs. The syntax is `<key_name>:<type_name>`. For example, to convert the key "k1" into integer, write `types k1:integer`. For the `time` type, one can write `<key_name>:time:<time_format>` to convert the string into a time object. For example, to convert the string "my_time=12/31/2014 12:00:00", use `my_time:time:%m/%d/%Y %H:%M:%S`. This parameter is same as the one used for [in_tail](https://docs.fluentd.org/articles/in_tail) and others (see under the "types" section over there).

## License

Apache 2.0. Copyright Kiyoto Tamura
