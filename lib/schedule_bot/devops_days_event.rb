# frozen_string_literal: true

module ScheduleBot
  # This is an event on a DevOpsDays program.
  class DevOpsDaysEvent
    attr_accessor :type, :speaker, :time

    def initialize(type:, speaker:, time:)
      @type = type
      @speaker = speaker
      @time = time
    end
  end
end
