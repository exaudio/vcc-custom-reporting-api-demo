require 'json'
require 'net/https'

# This class contains requests a new access token for inContact's API
class Authorization
  def initialize(credentials)
    @credentials = credentials
  end

  # get an OAuth 2.0 access toke from inContact
  def request_token
    username = @credentials['username']
    password = @credentials['password']
    # app_name = @credentials['app_name']
    app_name = @credentials['app_name']
    vendor_name = @credentials['vendor_name']
    bus_num = @credentials['bus_num']
    scope = @credentials['scope']

    payload_hash = {
      'grant_type' => 'password',
      'username' => username,
      'password' => password,
      'scope' => scope
    }

    # The user name for inContact's API takes the form
    # app_api_name = "#{app_name}" + "@" + "#{vendor_name}" + ":" + "#{bus_num}"
    api_app_name = "#{app_name}" + "@" + "#{vendor_name}"

    puts "Authorizing... \n"

    # Specify token URL.
    url = URI('https://api.incontact.com/InContactAuthorizationServer/Token')
    # url = URI('https://api-c71.nice-incontact.com/InContactAuthorizationServer/Token')

    # Create connection object
    connection = Net::HTTP.new(url.host, url.port)
    # At *work*:
    # connection = Net::HTTP.new(url.host, url.port, 'asqproxy.vzbi.com', 80)
    # For *Fiddler*
    # connection = Net::HTTP.new(url.host, url.port, '127.0.0.1', 8888)

    connection.use_ssl = true
    # Uncomment the following line to tell Ruby to ignore invalid security certs.
    # connection.verify_mode = OpenSSL::SSL::VERIFY_NONE

    # Create post object
    post = Net::HTTP::Post.new(url)

    # OAuth 2 token requests are usually the 'user' + 'pass' base64 encoded
    post.basic_auth(api_app_name, bus_num)

    # get the POST post _fileheaders
    # post['Content-Type'] = 'audio/flac'
    post['Content-Type'] = 'application/json; charset=UTF-8'
    post['Accept'] = 'application/json'
    # "Accept-Encoding" => "gzip, deflate, sdch, br",
    post['Accept-Encoding'] = 'none'
    post['Connection'] = 'keep-alive'

    # Prepare the HTTP message body to be posted with the request.
    # Convert the payload_hash hash to a json string.
    payload = payload_hash.to_json
    # It will be the message body (payload) of the HTTP post.
    post.body = payload

    # Make the HTTP post request and store the response.
    # The 'begin' & 'rescue' is an aborted attempt to put
    # error/exception handling around the http post
    # *begin*
    # *rescue* StandardError
    # *end*
    response = connection.request(post)

    # http_status_code = response.code.to_i
    http_status_code = response.code.strip
    if http_status_code.chr != '2'
      # Show me http status code
      puts "/n http_status_code: #{http_status_code}"
    end

    if response.is_a?(Net::HTTPSuccess)
      puts "response is a Net::HTTPSuccess object"
      # if response is OK then parese it to a Ruby data structure
      access_token_hash = JSON.parse(response.body)
      # access_token = access_token_hash['access_token']
    end

    access_token_hash
  end
end
