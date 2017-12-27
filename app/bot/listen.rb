require "facebook/messenger"
include Facebook::Messenger
require_relative "setup"
require_relative "workflow"
include Workflow

require 'byebug'

# message.id          # => 'mid.1457764197618:41d102a3e1ae206a38'
# message.sender      # => { 'id' => '1008372609250235' }
# message.sent_at     # => 2016-04-22 21:30:36 +0200
# message.text        # => 'Hello, bot!'



# Storage for Temporarily Saving Incomplete Entries: { `facebook_id`: { date: `12/25/2017`, mood: `content`, text: `` } }
temp_storage = {}
#byebug

# Server address
SERVER_URL = "https://f4a3be0c.ngrok.io"
# Path to image from app directory
IMAGE_PATH = File.join(File.expand_path('.'), 'app', 'assets', 'images')
# Action collection
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
# Actions associated with Menu
MENU_ACTS = "#{ACTIONS[:menu_reason]},#{ACTIONS[:menu_act]},#{ACTIONS[:menu_show_specific]},#{ACTIONS[:menu_show_all]}"

# Sets up menu and get started button
SetUp.enable

# Handles messages
Bot.on :message do |message|
  user_id = message.sender['id']
  db_user = User.find_by_facebook_id user_id
  if db_user
    permitted = db_user.actions
    # Only one action other than menu is allowed for messages
    curr_action = permitted.split(",").last
    case curr_action
    when ACTIONS[:date]
      Workflow.date_message message, db_user
      db_user.actions = MENU_ACTS
      db_user.save
    when ACTIONS[:log]
      Workflow.handle_log message
      temp_storage[user_id][:text] = message.text
      db_user.actions = MENU_ACTS + ",#{ACTIONS[:submit_yes]},#{ACTIONS[:submit_no]}"
      db_user.save
    else
      Workflow.redirect_message message
      db_user.actions = MENU_ACTS
      db_user.save
    end
  else
    Workflow.redirect_message message
    db_user.actions = MENU_ACTS
    db_user.save
  end
end

# Handles postbacks
Bot.on :postback do |postback|
  user_id = postback.sender['id']
  db_user = User.find_by_facebook_id user_id
  if db_user
    permitted_array = db_user.actions.split(",")
    if permitted_array.include? postback.payload
      case postback.payload
      when ACTIONS[:menu_reason]
        Workflow.explain_benefits postback
        db_user.actions = MENU_ACTS
        db_user.save
      when ACTIONS[:menu_act]
        #Workflow.begin_routine user_id
        Workflow.begin_routine postback
        # Initialize the temporary storage entry for user_id
        temp_storage[user_id] = { date: "not initialized", mood: "not initialized", text: "not initialized" }
        db_user.actions = MENU_ACTS + ",#{ACTIONS[:mood_good]},#{ACTIONS[:mood_okay]},#{ACTIONS[:mood_bad]}"
        db_user.save
      when ACTIONS[:menu_show_specific]
        Workflow.ask_for_formatted_date postback
        db_user.actions = MENU_ACTS + ",#{ACTIONS[:date]}"
        db_user.save
      when ACTIONS[:menu_show_all]
        Workflow.show_all_logs postback, db_user
        db_user.actions = MENU_ACTS
        db_user.save
      when ACTIONS[:learn_more]
        Workflow.learn_more postback
        db_user.actions = MENU_ACTS + ",#{ACTIONS[:begin_routine]}"
        db_user.save
      when ACTIONS[:begin_routine]
        #Workflow.begin_routine user_id
        Workflow.begin_routine postback
        # Initialize the temporary storage entry for user_id
        temp_storage[user_id] = { date: "not initialized", mood: "not initialized", text: "not initialized" }
        db_user.actions = MENU_ACTS + ",#{ACTIONS[:mood_good]},#{ACTIONS[:mood_okay]},#{ACTIONS[:mood_bad]}"
        db_user.save
      when ACTIONS[:mood_good]
        Workflow.handle_mood postback
        temp_storage[user_id][:mood] = "Content"
        db_user.actions = MENU_ACTS + ",#{ACTIONS[:log]}"
        db_user.save
      when ACTIONS[:mood_okay]
        Workflow.handle_mood postback
        temp_storage[user_id][:mood] = "Okay"
        db_user.actions = MENU_ACTS + ",#{ACTIONS[:log]}"
        db_user.save
      when ACTIONS[:mood_bad]
        Workflow.handle_mood postback
        temp_storage[user_id][:mood] = "Discontent"
        db_user.actions = MENU_ACTS + ",#{ACTIONS[:log]}"
        db_user.save
      when ACTIONS[:submit_yes]
        Workflow.confirm_submit postback
        # Save the temporary entry to the database
        db_user.entries.create(date: Date.today.to_s, mood: temp_storage[user_id][:mood], text: temp_storage[user_id][:text])
        db_user.actions = MENU_ACTS
        db_user.save
      when ACTIONS[:submit_no]
        Workflow.unconfirm_submit postback
        db_user.actions = MENU_ACTS + ",#{ACTIONS[:log]}"
        db_user.save
      end
    else
      Workflow.redirect_message postback
      db_user.actions = MENU_ACTS
      db_user.save
    end
  else
    if postback.payload == ACTIONS[:start]
      Workflow.introduction postback
      new_user = User.create(facebook_id: user_id, actions: MENU_ACTS + ",#{ACTIONS[:learn_more]}")
    end
  end
end