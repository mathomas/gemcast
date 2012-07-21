#!/usr/bin/ruby

require "engine.rb"
require "environment.rb"

env = Environment.new
http_response = HttpPrinter.new(env)

criteria = Criteria.new(env.get_query_path)
store = Factory.for_name(Config::STORE_CLASS).new

# TODO:  figure out how to best handle "flavors".
if criteria.flavor_html?
  responder = Weblog.new(criteria, store)
else
  responder = RssFeed.new(criteria, store)
end

http_response.write(responder.generate_content)
print http_response.content




