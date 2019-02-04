require 'net/https'
require 'json'
require 'base64'

class ReportFile
  def initialize(auth_token, status)
    @access_token = auth_token['access_token']
    @base_uri = auth_token['resource_server_base_uri']
    @job_id = status['jobResult']['jobId']
    @file_name = status['jobResult']['fileName']
    @file_url = status['jobResult']['resultFileURL']
    @file_state = status['jobResult']['state']
  end

  # GET /files
  def get_file
    # resource = "services/v13.0/files/" + @file_name

    # Assemble URL
    # url = URI(@base_uri + resource)
    url = URI(@file_url)

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
      report_file_hash = response_body_hash
    else
      puts "HTTP request failed"
      report_file_hash = "error"

    end
    report_file_hash
    @report_file_hash = report_file_hash
  end

  def write_to_disk(destination_file_path)
    # Prep the destination file path and name
    file_name = @report_file_hash['files']['fileName']
    file_path_name = destination_file_path + "/" + file_name
    
    # Prep file content to be written
    file_content_base64 = @report_file_hash['files']['file']
    file_content_binary = Base64.decode64(file_content_base64)
    
    # Write the file
    File.open(file_path_name, "wb") do |f|
      f.write(file_content_binary)
    end
    puts "file written"
    return
  end
end
