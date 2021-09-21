# frozen_string_literal: true

require 'httparty'
require 'logger'

module ScheduleBot
  # This is a DevOpsDays program.
  class DevOpsDaysProgram
    attr_accessor :city, :year, :start_time

    @logger = nil
    @events = {}

    def initialize(city:, year:)
      @logger = Logger.new($stdout)
      @logger.level = ENV['LOG_LEVEL'] || Logger::INFO
      @city = city
      @year = year
      @start_time = Time.now.strftime('%s').to_i
    end

    def fetch_events!
      response = HTTParty.get(events_uri)
      raise "Failed to retrieve #{events_uri}: #{response.code}" if response.code != 200

      @logger.debug("Response: #{response.body}")
      YAML.load(response.body)['program'] # Some "non-existent" times are making safe_load fail
    end

    def find_events(within:)
      @events ||= fetch_events!
      raise "DevOpsDays Program for #{city} at #{year} not found." if @events.empty?

      found = []
      @events.each do |event|
        offset = Time.now.strftime('%:z')
        event_date =
          DateTime.parse("#{event['date']} #{event['start_time']} #{offset}").strftime('%s').to_i
        speaker = event['title'].gsub('-', ' ').capitalize
        type = event['type']
        seconds_until = event_date - @start_time
        @logger.debug("Now: #{Time.at(@start_time)}, Seconds until #{speaker} at #{Time.at(event_date)} goes up: #{seconds_until}")
        next unless seconds_until.positive? && seconds_until <= ChronicDuration.parse(within)

        found << DevOpsDaysEvent.new(speaker: speaker,
                                     type: type,
                                     time: event_date)
      end
      found
    end

    def events_uri
      "https://raw.githubusercontent.com/devopsdays/devopsdays-web/\
main/data/events/#{@year}-#{@city.downcase}.yml"
    end
  end
end
