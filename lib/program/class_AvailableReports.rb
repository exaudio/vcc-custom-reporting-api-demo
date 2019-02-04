require 'net/http'
require 'json'

# Returns
class AvailableReports
  def initialize(auth_token)
    @auth_token = auth_token
  end

  # this function calls the GET /reports
  def get_list
    # Pull the access token and base URL from the response body.
    accessToken = @auth_token['access_token']
    base_uri = @auth_token['resource_server_base_uri']

    # Create the URL that accesses the API.
    # GET https://api-c7.incontact.com/inContactAPI/services/v13.0/reports
    resource = 'services/v13.0/reports'

    # fields = "abandoned,abandonSeconds,agentId,agentSeconds,contactId,contactStart,firstName,fromAddr,holdCount,holdSeconds,inQueueSeconds,isOutbound,isRefused,lastName,masterContactId,mediaType,mediaTypeName,pointOfContactName,preQueueSeconds,routingTime,serviceLevelFlag,skillId,skillName,toAddr,totalDurationSeconds"
    # query_string_params = "?startDate=" + @start_date + "&endDate=" + @end_date + "&fields=" + fields + "&mediaTypeId=4"
    query_string_params = ""

    # Assemble URL
    url = URI(base_uri + resource + query_string_params)

    http = Net::HTTP.new(url.host, url.port)
    # http.read_timeout = 1000
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Content-Type"] = 'application/x-www-form-urlencoded'
    request["Authorization"] = "Bearer #{accessToken}"
    request["Accept"] = 'application/json'
    request["Accept-Encoding"] = 'none'
    request["cache-control"] = 'no-cache'
    request["Connection"] = 'keep-alive'

    # Make the HTTP post request and store the response.
    response = http.request(request)

    # http_status_code = response.code.to_i
    http_status_code = response.code.strip

    # Show me http status code
    puts "http_status_code: #{http_status_code}"
    # http_status_code.chr == '2'

    # When response is OK then parese it to a Ruby data structure
    if response.is_a?(Net::HTTPSuccess)
      puts "Success. Response was a Net::HTTPSuccess object"
      puts "List of available reports was returned."
      response_string = response.body
      response_body_hash = JSON.parse(response_string)
      available_reports = response_body_hash
    else
      puts "HTTP request failed"
      available_reports = "error"
    end

    available_reports
  end
end
