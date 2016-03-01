require 'open-uri'
require 'robotstxt'

def robots_exists? url
  uri = URI(url)
  request = Net::HTTP.new uri.host
  response= request.request_head uri.path
  if([301,302].include? response.code.to_i) #moved
    return robots_exists? response['location']
  end
  return response.code.to_i == 200
end

def is_allowed url
  test = Robotstxt::Parser.new('site_info_bot')
  test.get url
  return test.allowed? url
end

def get_site_info params
  doc =  Nokogiri::HTML(open(params['site']))
  json = {}
  if params.has_key?("lookup")  then
    json['has_lookup'] = doc.to_s.include? params["lookup"]
    json['lookup_term'] = params['lookup']
  end
  json['robots_file_exists']=robots_exists?(params['site'] +'/robots.txt')
  if (is_allowed(params['site'])) then
    json['is_fetch_allowed'] = true
    json['html'] = doc.to_s
  else
    json['is_fetch_allowed'] = false
  end
  json['is_using_bootstrap'] = doc.xpath('//link[@rel="stylesheet"]').to_s.include?('bootstrap.min.css') #Grab all stylesheet links, turn them into text and search for bootstrap
  return json
end
