require 'net/https'
require 'json'

class ReportJob
  def initialize(auth_token, report_id, query_params)
    @access_token = auth_token['access_token']
    @base_uri = auth_token['resource_server_base_uri']
    @report_id = report_id
    @query_params = query_params
  end

  # start a report id return a job id
  def start_report
    # Check that the token is a valid token.
    if @access_token.nil? || @base_uri.nil?
      raise ArgumentError, 'ReportJob.start_report() did not receive a token it could understand'
    end

    # Create the URL that accesses the API.
    # POST # url = URI('https://api-c7.incontact.com/inContactAPI/services/v13.0/report-jobs/11250?fileType=Excel&includeHeaders=true&appendDate=false&deleteAfter=7&overwrite=true&startDate=2019-02-01T00%3A00%3A00&endDate=2019-02-01T23%3A59%3A59')
    resource = 'services/v13.0/report-jobs/' + @report_id

    query_string = URI.encode_www_form(@query_params)

    # Assemble URL
    # url = URI(baseURL + resource + query_string_params)
    url = URI.parse(@base_uri + resource + "?" + query_string)

    # informational
    puts url

    connection = Net::HTTP.new(url.host, url.port)
    # At *work*:
    # connection = Net::HTTP.new(url.host, url.port, 'asqproxy.vzbi.com', 80)
    # For *Fiddler*
    # connection = Net::HTTP.new(url.host, url.port, '127.0.0.1', 8888)
    connection.use_ssl = true
    # Uncomment the following line to tell Ruby to ignore invalid security certs.
    connection.verify_mode = OpenSSL::SSL::VERIFY_NONE

    # request = Net::HTTP::Post.new(url, headers)
    request = Net::HTTP::Post.new(url)

    # request['Content-Type'] = 'audio/flac'
    request['Content-Type'] = 'application/x-www-form-urlencoded'
    request['Authorization'] = "Bearer #{@access_token}"
    request['Accept'] = 'application/json'
    request['Accept-Encoding'] = 'none'
    request['cache-control'] = 'no-cache'
    request['Connection'] = 'keep-alive'

    # Prepare HTTP message body to be posted with the request
    # payload = payload_hash.to_json
    # request.body = payload
    # request.body = ''

    # Make the HTTP post request and store the response.
    # The 'begin' & 'rescue' is an attempt to put
    # error/exception handling around the http post
    # *begin*
    # *rescue* StandardError
    # *end*
    response = connection.request(request)

    # http_status_code = response.code.to_i
    http_status_code = response.code.strip
    if http_status_code.chr == '2'
    else
        # show me http status code
        puts "/n http_status_code: #{http_status_code}"
    end

    # response is OK then parse it to a Ruby data structure
    if response.is_a?(Net::HTTPSuccess)
      puts "response is a Net::HTTPSuccess object"
      response_json = JSON.parse(response.body)
      job_id = response_json['jobId']
    else
       job_id = 0
    end
    # 
    @job_id = job_id
    
    job_id
  end

  def get_status(job_id)
    # GET /report-jobs/{jobId}
    resource = "services/v13.0/report-jobs/" + job_id

    # Assemble URL
    url = URI(@base_uri + resource)

    puts url

    http = Net::HTTP.new(url.host, url.port)
    # http.read_timeout = 1000
    http.use_ssl = true

    request = Net::HTTP::Get.new(url)
    request["Content-Type"] = 'application/x-www-form-urlencoded'
    request["Authorization"] = "Bearer #{@access_token}"
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
      puts "Report status returned."
      response_string = response.body
      response_body_hash = JSON.parse(response_string)
      report_status_hash = response_body_hash
    else
      puts "HTTP request failed"
      report_status_hash = "error"
    end

    report_status_hash
  end
end
