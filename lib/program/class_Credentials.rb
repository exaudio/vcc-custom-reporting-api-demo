require 'json'
# Manually retrieve an OAuth token (alternative is to use the Oath2 gem)
# * *Arguments*
# * *Returns*
class Credentials
  def initialize(file_name)
    @file_name = file_name
  end

  def read_creds
    # Open a file with account credentials
    # file_name = '../data/login_credentials.json'
    current_file = open(@file_name)
    file_contents_json = current_file.read
    file_contents_hash = JSON.parse(file_contents_json)

  end
end
