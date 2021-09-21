require 'spec_helper'

describe "Given a bot that posts what's up next on a DevOpsDays program" do
  it 'Posts when events are coming up next', :unit do
    Timecop.freeze(2021, 9, 21, 10, 20, 0)

    expected = <<~EXPECTED
      *:white_check_mark: Talks, ignites, and workshops coming up in 10 mins*

      - *[talk]* First talk @ 2021-09-21 10:30
    EXPECTED
    fake_slack = double(Slack::Web::Client)
    allow(Slack::Web::Client).to receive(:new).and_return(fake_slack)
    allow_any_instance_of(ScheduleBot::DevOpsDaysProgram)
      .to receive(:fetch_events!)
      .and_return(YAML.load(File.read('spec/fixtures/test_program.yml'))['program'])
    expect(fake_slack)
      .to receive(:chat_postMessage)
      .with(channel: '#fake_channel', text: expected)
    expect { ScheduleBot::Main.execute! }
      .not_to output(/No events found within 10 mins/).to_stdout

    Timecop.return
  end

  it 'Does not post anything to Slack when no events are coming up', :unit do
    Timecop.freeze(2021, 9, 23, 9, 5, 0)

    fake_slack = double(Slack::Web::Client)
    allow(Slack::Web::Client).to receive(:new).and_return(fake_slack)
    allow_any_instance_of(ScheduleBot::DevOpsDaysProgram)
      .to receive(:fetch_events!)
      .and_return(YAML.load(File.read('spec/fixtures/test_program.yml'))['program'])
    expect(fake_slack)
      .not_to receive(:chat_postMessage)
    expect { ScheduleBot::Main.execute! }.to output(/No events found within 10 mins/).to_stdout

    Timecop.return
  end
end
