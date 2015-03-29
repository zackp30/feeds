require 'nokogiri'
require 'net/http'
require 'uri'

document = Nokogiri::XML(open ENV['FILE_TO_VALIDATE'])

to_remove = []

nodes = document.xpath '//opml/body/outline'
nodes.each_with_index do |n,i|
  uri = URI.parse(n.attr 'xmlUrl')
  next if uri.path == ''
  print uri
  http = Net::HTTP.new(uri.host, uri.port)
  http.open_timeout = 5
  http.read_timeout = 5
  request = Net::HTTP::Get.new(uri.path)
  begin
    response = http.request(request)
    to_remove << uri.to_s unless [200, 201, 202, 302, 304, 503].include? response.code.to_i # I know 503 isn't exactly "successful", but this error is *usually* temporary.
    puts " --- #{response.code}"
  rescue Exception => error
    puts error
    puts ' --- timeout'
    to_remove << uri.to_s
  end
end

to_remove.each do |n|
  puts n
  document.search("//outline[@xmlUrl='#{n}']").remove
end

File.open('removed.xml', 'wt') { |f| f.print(document.to_xml) }
