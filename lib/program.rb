require './lib/program/class_Credentials.rb'
require './lib/program/class_Authorization.rb'
require './lib/program/class_AvailableReports.rb'
require './lib/program/class_ReportJob.rb'
require './lib/program/class_ReportJobStatus.rb'
require './lib/program/class_ReportFile.rb'

# start of "main" program
# read credentials from a file
file_name = './data/login_creds.json'
credentials = Credentials.new(file_name)
creds_hash = credentials.read_creds

# Use the credentials from above to authorize
# and retrieve authorization object containing access_token
authorization = Authorization.new(creds_hash)
auth_hash = authorization.request_token

# Get a list of reports available to run
# GET https://api-c7.incontact.com/inContactAPI/services/v13.0/reports
# This seems to return a list of available data download reports
# available_reports_obj = AvailableReports.new(auth_hash)
# available_reports = available_reports_obj.get_list
# puts available_reports.to_s

# The report ID numbers below are for custom reports 
# and are unique to a business unit.
# Set up the reports paramaters
report_id = '11250'
report_params = {
  'fileType' => 'Excel',
  'includeHeaders' => 'true',
  'appendDate' => 'false',
  'deleteAfter' => '7',
  'overwrite' => 'true',
  'startDate' => '2019-02-01T00:00:00',
  'endDate' => '2019-02-01T23:59:59'
}

# Run the report using the report params from above
report_job = ReportJob.new(auth_hash, report_id, report_params)
job_id = report_job.start_report
# job_id = "826183"

loop_start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
loop do
  # Wait for report to finish running
  sleep(10)

  # Check report status to see if it's finished
  unless job_id.nil?
    report_job = ReportJobStatus.new(auth_hash, job_id)
    status_hash = report_job.get_status
    @status_hash = status_hash
    status = status_hash['jobResult']['state'].downcase
    @status = status
  end

  current_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  et = current_time - loop_start_time
  et = et.ceil

  puts "Elapsed time: #{et}, status: #{status}"

  break if status == 'finished' || et > 300
end

# Once the report's status is 'finished' download to memory
if @status == 'finished'
  report = ReportFile.new(auth_hash, @status_hash)
  report.get_file
end

# Set the destination path where the report file should get saved
# destination_file_path = "/home/jon/"
destination_file_path = Dir.home
# Write the file to disk
report.write_to_disk(destination_file_path)
