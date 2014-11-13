#edited by Rufat
require 'selenium-webdriver'
start_time = Time.now
#########################################################
user = ENV['USER']
email = 'andy.gurbanov@gmail.com'
date = Time.now.to_s[0..18]
#########################################################
if RUBY_PLATFORM =~ /linux/; os = 'Linux'
elsif RUBY_PLATFORM =~ /32/; os = 'Windows'
elsif RUBY_PLATFORM =~ /darwin11/; os = 'Mac OS X 10.7 Lion'
elsif RUBY_PLATFORM =~ /darwin12/; os = 'OS X 10.8 Mountain Lion'
elsif RUBY_PLATFORM =~ /darwin13/; os = 'OS X 10.9 Mavericks'
elsif RUBY_PLATFORM =~ /darwin14/; os = 'OS X 10.10 Yosemite'
end
file_name = __FILE__.split('/').to_a.last.to_s
ruby_version = RUBY_VERSION
description = 'Basic Search Scenario for KAYAK website'
#########################################################
#Data Input and Output Files
input = File.open('INPUT.csv')
output = File.new('OUTPUT.txt', 'w')
#########################################################
output.puts '*********************************************************************'
output.puts "\# User \s\s\s\s\s\s\s\s: #{user}"
output.puts "\# Email \s\s\s\s\s\s\s: #{email}"
output.puts "\# Date \s\s\s\s\s\s\s\s: #{date}"
output.puts "\# OS\s\s\s\s\s\s\s\s\s\s\s: #{os}"
output.puts "\# Ruby Version\s: #{ruby_version} "
output.puts "\# Script\s\s\s\s\s\s\s: #{file_name}"
output.puts "\# Description\s\s: #{description}"
output.puts '*********************************************************************'
#########################################################
##### Start Time
output.puts '************ Test started at: ' + start_time.to_s + '  ************'

#########################################################
##### Object Properties Storage
$i = 0 #Rescue loop
landing_page_title = 'KAYAK - Cheap Flights, Hotels, Airline Tickets, Cheap Tickets, Cheap Travel Deals - Compare Hundreds of Travel Sites At Once'
search_results_title = 'KAYAK Search Results'
origin_airport_field_id = 'origin'
nearby_origin = 'nearbyO'
destination_airport_field_id = 'destination'
nearby_destination = 'nearbyD'
start_date = "//*[@id='travel_dates-start-placeholder']"
end_date = "//*[@id='travel_dates-end-placeholder']"
find_flights_button = 'fdimgbutton'

search_result_page_el = "//*[@id='sectioncount']/a"
search_result_number = "//*[@id='sectioncount']/span[1]"

#search_res_origin_airport = 'inlineorigin'                                             #ID
search_res_origin_airport = "//*[@id='inlinesearchblock']/div[1]/div[1]/span[1]"        #xpath
#search_res_destination_airport = "inlinedestination"                                   #ID
search_res_destination_airport = "//*[@id='inlinesearchblock']/div[1]/div[1]/span[3]"   #xpath
#########################################################
input.each do |line|
  #### If input line equals to 'stop_execution' script should stop execution
  if line.include? 'stop_execution'
    finish_time = Time.now
    output.puts '************ Test finished:  ' + finish_time.to_s + '   ************ Duration:  ' + (finish_time - start_time).to_s + '  ************'
    input.close
    output.close
    exit
  end

  #### Beginning of the rescue
  begin
    browser = Selenium::WebDriver.for :chrome
    browser.manage.timeouts.implicit_wait = 10
    browser.manage.window.maximize
    #### Extracting data from CSV data file
    data = line.split(',')
    t_case_number = data [0]
    origin_airport = data[1]
    destination_airport = data[2]
    departure_date = data[3]
    return_date = data[4]
    output.puts "************ Test Case: ##{t_case_number}"

    #### Browser navigate to www.kayak.com
    browser.get('http://www.kayak.com/') # browser.navigate.to 'url'

    #### Landing Page Title Assertion
    (browser.title == landing_page_title) ? (output.puts "***PASSED*** Landing Page Title is: #{landing_page_title}"): (output.puts "***FAILED*** Couldn't verify Landing Page")

    #### Origin Airport (From:)
    sleep(1)
    browser.find_element(:id, origin_airport_field_id).clear
    browser.find_element(:id, origin_airport_field_id).send_keys origin_airport
    output.puts "***PASSED*** Origin Airport selected as: #{origin_airport}"
    browser.find_element(:id, nearby_origin).click

    #### Destination Airport (To:)
    sleep(1)
    browser.find_element(:id, destination_airport_field_id).clear
    browser.find_element(:id, destination_airport_field_id).send_keys destination_airport
    output.puts "***PASSED*** Destination Airport selected as: #{destination_airport}"
    browser.find_element(:id, nearby_destination).click

    #### Depart Date
    sleep(1)
    browser.find_element(:xpath, start_date).click
    sleep(1)
    browser.find_element(:xpath, departure_date).click

    #### Return Date
    sleep(1)
    browser.find_element(:xpath => end_date).click
    sleep(1)
    browser.find_element(:xpath => return_date).click

    #### Find Flights Button
    browser.find_element(:id, find_flights_button).click

    #### Assertion of the Search Results Page
    browser.title == search_results_title ? (output.puts "***PASSED*** #{search_results_title} has been opened"):(output.puts "***FAILED*** Couldn't verify search results page: #{search_results_title}")

    #### Waiting for Search Results Page
    sleep(15)
    wait = Selenium::WebDriver::Wait.new(:timeout => 30)
    wait.until { browser.find_element(:xpath => search_result_page_el) }

    #### Number of Search Results
    output.puts "***PASSED*** Total Number of Displayed Search Results: #{browser.find_element(:xpath, search_result_number).text}"

    #### Assertion of the Origin Airport Details
    # Different UI #from = browser.find_element(:id, search_res_origin_airport).attribute('value')
    from = browser.find_element(:xpath => "//*[@id='inlinesearchblock']/div[1]/div[1]/span[1]").text
    (from.include? origin_airport) ? (output.puts "***PASSED*** Search Result for #{from} contains #{origin_airport}"): (output.puts "***FAILED*** Search Result for #{from} doesn't contains #{origin_airport}")

    ##### Assertion of the Destination Details
    #to = browser.find_element(:id, search_res_destination_airport).attribute('value')
    to = browser.find_element(:xpath => "//*[@id='inlinesearchblock']/div[1]/div[1]/span[3]").text
    (to.include? destination_airport) ? (output.puts "***PASSED*** Search Result for #{to} contains #{destination_airport}"): (output.puts "***FAILED*** Search Result for #{to} doesn't contains #{destination_airport}")

      # Error Handling
  rescue Net::ReadTimeout
    output.puts '***FAILED*** Net::ReadTimeout'
  rescue NoMethodError
    output.puts '***FAILED*** No method Error'
  rescue Selenium::WebDriver::Error::StaleElementReferenceError
    output.puts '***FAILED*** Selenium::WebDriver::Error::StaleElementReferenceError'
  rescue Selenium::WebDriver::Error::NoSuchElementError
    output.puts '***FAILED*** Selenium::WebDriver::Error::NoSuchElementError'
  rescue Selenium::WebDriver::Error::UnknownError
    output.puts '***FAILED*** Selenium::WebDriver::Error::UnknownError'           # Intentional Error. In order to avoid it please add Departure and Return Dates to the line #2 in the INPUT.csv file
  rescue Selenium::WebDriver::Error::InvalidSelectorError
    output.puts '***FAILED*** Selenium::WebDriver::Error::InvalidSelectorError'   # Intentional Error. In order to avoid it please add Return Date to the line #3 in the INPUT.csv file
  rescue Selenium::WebDriver::Error::TimeOutError
    output.puts '***FAILED*** Selenium::WebDriver::Error::TimeOutError'           # Possible Intentional Error. In order to avoid it please increase explicit wait time in the Line #110 (up to 60 sec)
    # Following Loop while try several attempts, before script will be stopped
    until $i == 5
      $i += 1
      browser.quit
      output.puts "************ New Attempt for Test Case# #{t_case_number}"
      retry
    end
  rescue Selenium::WebDriver::Error::ElementNotVisibleError
    output.puts '***FAILED*** Selenium::WebDriver::Error::ElementNotVisibleError'
    output.puts "************ New Attempt for Test Case# #{t_case_number}"
    retry
  end
  browser.quit
end
# Closing Input and Output Files
input.close
output.close


