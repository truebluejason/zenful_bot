require "facebook/messenger"
include Facebook::Messenger
require_relative "workflow"
include Workflow

require 'byebug'

# message.id          # => 'mid.1457764197618:41d102a3e1ae206a38'
# message.sender      # => { 'id' => '1008372609250235' }
# message.sent_at     # => 2016-04-22 21:30:36 +0200
# message.text        # => 'Hello, bot!'



# Format: { `facebook_id`: { actions: [`action_1`, `action_2`, ...], saved: `value` } }, with menu actions first and other actions after

ACTIONS = {
  menu_reason: 'EXPLAIN',
  menu_act: 'ACTION',
  menu_show_specific: 'SPECIFIC',
  date: 'DATE',
  menu_show_all: 'SHOW_ALL',
  start: 'GET_STARTED_PAYLOAD',
  learn_more: 'LEARN',
  begin_routine: 'BEGIN',
  mood_good: 'CONTENT',
  mood_okay: 'OKAY',
  mood_bad: 'DISCONTENT',
  log: 'LOG',
  submit_yes: 'SUBMIT',
  submit_no: 'RETRY'
}

Bot.on :message do |message|
  user_id = message.sender

  users = MemberDB.all
  if users.key? user_id
    curr_action = users[:user_id][:actions].last
    case curr_action
    when ACTIONS[:date]
      # Direct to date handling method
      # Update user's permitted actions
    when ACTIONS[:log]
      # Direct to log handling method
      # Update user's permitted actions
    else
      # Direct to I don't understand method
    end
    # Save to member table
  else
    # Direct to I don't understand method
  end
end

Bot.on :postback do |postback|
  user_id = postback.sender

  users = MemberDB.all
  if users.key? user_id
    if users[:user_id][:action].include? postback.payload
      case postback.payload
      when ACTIONS[:menu_reason]
        # Direct to menu_reason handling method
        # Update user's permitted actions
      when ACTIONS[:menu_act]
        # Direct to menu_act handling method
        # Update user's permitted actions
      when ACTIONS[:menu_show_specific]
        # Direct to menu_show_specific handling method
        # Update user's permitted actions
      when ACTIONS[:menu_show_all]
        # Direct to menu_show_all handling method
        # Update user's permitted actions
      end
      # Save to member table
    else
      # Direct to I don't understand method
    end
  else
    if postback.payload == ACTIONS[:start]
      # Generate a table with ActiveRecord with log_id, date, feeling, and user_log
    end
  end
end