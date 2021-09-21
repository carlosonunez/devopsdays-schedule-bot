# frozen_string_literal: true

require 'yaml'
require 'chronic_duration'
require 'slack-ruby-client'
require 'date'
require 'time'
require 'schedule_bot/devops_days_program'
require 'schedule_bot/devops_days_event'

module ScheduleBot
  # The show!
  class Main
    @logger = nil
    @city = ENV['DEVOPS_DAYS_CITY'] or raise 'Please define DEVOPS_DAYS_CITY'
    @channel = ENV['SLACK_CHANNEL'] or raise 'Please define SLACK_CHANNEL'
    @year = Time.now.year
    @events_within = ENV['FIND_EVENTS_WITHIN'] || '10m'
    @events_within_human = ChronicDuration.output(ChronicDuration.parse(@events_within))

    def self.execute!
      start_logging!
      initialize_slack!

      program = DevOpsDaysProgram.new(city: @city, year: @year)
      events = program.find_events(within: @events_within)
      if events.empty?
        @logger.info("No events found within #{@events_within_human}")
        exit(0)
      end

      message = "*:white_check_mark: Talks, ignites, and workshops coming up in #{@events_within_human}*\n\n"
      events.each do |event|
        human_time = Time.at(event.time).strftime('%F %R')
        message += "- *[#{event.type}]* #{event.speaker} @ #{human_time}\n"
      end

      @logger.info("Going to send: #{message} to #{@channel}")
      slack = ::Slack::Web::Client.new
      slack.chat_postMessage(channel: @channel,
                             text: message)
      @logger.info('Bot complete')
    end

    def self.start_logging!
      @logger = Logger.new($stdout)
      @logger.level = ENV['LOG_LEVEL'] || Logger::INFO
    end

    def self.initialize_slack!
      raise 'Please define SLACK_API_TOKEN' if ENV['SLACK_API_TOKEN'].nil?

      ::Slack.configure do |config|
        config.token = ENV['SLACK_API_TOKEN']
        config.logger = Logger.new($stdout)
        config.logger.level = ENV['LOG_LEVEL'] || Logger::INFO
      end
    end
  end
end
