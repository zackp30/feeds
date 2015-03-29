# This script turns a load of li's into an OPML.
# Crude, but does the job.

require 'nokogiri'
require 'open-uri'

document = Nokogiri::HTML(open(ENV['EXTRACT_URL']))

nodes = document.xpath ENV['XPATH']

nodes.each do |n|
  puts n.xpath('a[1]').attr 'title'
  puts `echo "$(OPML_XML_URL="#{n.xpath('a[2]').attr 'href'}" OPML_HTML_URL="#{n.xpath('a[1]').attr 'href'}" OPML_TITLE="#{n.xpath('a[1]').attr 'title'}" erb opml.erb)" >> new.opml`  # the `a[N]` might have to be adjusted
end
