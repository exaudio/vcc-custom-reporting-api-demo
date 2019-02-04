require 'net/https'
require 'json'

class ReportJobStatus
  def initialize(auth_token, job_id)
    @access_token = auth_token['access_token']
    @base_uri = auth_token['resource_server_base_uri']
    @job_id = job_id
  end

  # GET /report-jobs/{jobId}
  def get_status
    resource = "services/v13.0/report-jobs/" + @job_id

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
