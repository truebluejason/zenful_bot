require "facebook/messenger"
include Facebook::Messenger
require_relative "helpers"
include Helpers

#require 'byebug'

module Workflow

##############################################################################################
# MISC Methods
##############################################################################################

  # When user does something that is not allowed, redirect them to interact with the menu only
	def redirect_message pb
    image_reply(pb, "https://memegenerator.net/img/images/600x600/9746511/hmm-tea.jpg")
    text_reply(pb, "Something is off. Please interact with the menu again.")
	end

  # Tells the user to type the date message again
  def invalid_date msg
    text_reply(msg, "The date you entered isn't properly formatted. Please interact with the menu.")
  end

##############################################################################################
# Menu Related Methods
##############################################################################################

  # Sends the user scientific benefits of doing gratitude exercises
  def explain_benefits pb
    text_reply(pb, "Studies have shown that cultivating thankfulness on a daily basis can improve people's quality of life.")
    text_reply(pb, "Here are some links to different articles and papers, so you can see the results and assess the benefits for yourself.")
    text_reply(pb, 'https://www.health.harvard.edu/newsletter_article/in-praise-of-gratitude')
    text_reply(pb, 'https://www.ncbi.nlm.nih.gov/pubmed/12585811')
    text_reply(pb, 'https://www.ncbi.nlm.nih.gov/pubmed/20515249')
  end

  # Ask for formatted date to display logs from a date correctly
  def ask_for_formatted_date pb
    text_reply(pb, "Please type the date of interest (including the year).")
  end

  # Checks if NLP is available, then take the appropriate action
  def date_message msg, db_user
    begin
      nlp = msg.messaging["message"]["nlp"]["entities"]["datetime"][0]["value"]
      date = Date.parse(nlp).to_s
      show_logs_from_date msg, date, db_user
    rescue
      invalid_date msg
    end
  end

  # Fetches database rows with the specified date and sends a message for each log
  def show_logs_from_date msg, date, db_user
    id = msg.sender['id']
    # You obtain entries through the database's user id, not facebook's user id
    past_user_entries = Entry.where(user_id: db_user.id, date: date)
    if past_user_entries.empty?
      text_reply(msg, "You don't have any entries on that date. However, you have entries on the following dates:")
      Entry.where(user_id: db_user.id).each do |entry|
        text_reply(msg, "#{entry.date}")
      end
      text_reply(msg, "Please interact with the menu.")
    else
      past_user_entries.each do |entry|
        text_reply(msg, "Date: #{entry.date} – You felt: #{entry.mood}")
        text_reply(msg, "You were glad about: \"#{entry.text}\"")
      end
      text_reply(msg, "That's it! Feel free to interact with the menu more.")
    end
  end

  # Fetches the user's past responses from the database and sends a message for each log
  def show_all_logs pb, db_user
    # You obtain entries through the database's user id, not facebook's user id
    past_user_entries = Entry.where(user_id: db_user.id)
    if past_user_entries.empty?
      text_reply(pb, "You don't have any entries! Create one by clicking 'I'll tell you about today now.' button from the menu.")
    else
      past_user_entries.each do |entry|
        text_reply(pb, "Date: #{entry.date} – You felt: #{entry.mood}")
        text_reply(pb, "You were glad about: \"#{entry.text}\"")
      end
      text_reply(pb, "That's it! Feel free to interact with the menu more.")
    end
  end

##############################################################################################
# Regular Workflow Methods
##############################################################################################
=begin
  # Routine that asks user to rate their day and logs his grateful message
  def begin_routine id
    content = {
      attachment: {
        type: 'template',
        payload: {
          template_type: 'button',
          text: "How did you feel today?",
          buttons: [
            {type: 'postback', title: 'Content', payload: ACTIONS[:mood_good]},
            {type: 'postback', title: 'Okay', payload: ACTIONS[:mood_okay]},
            {type: 'postback', title: 'Discontent', payload: ACTIONS[:mood_bad]}
          ]
        }
      }
    }
    send_msg_first id, content
  end
=end

  # BETA TESTING method that asks user to rate their day and logs his grateful message
  def begin_routine pb
    button_reply(pb, "How did you feel today?",
      [{type: 'postback', title: 'Content', payload: ACTIONS[:mood_good]},
      {type: 'postback', title: 'Okay', payload: ACTIONS[:mood_okay]},
      {type: 'postback', title: 'Discontent', payload: ACTIONS[:mood_bad]}])
  end

  # Routine that asks user to rate their day and logs his grateful message
  def handle_mood pb
    case pb.payload
    when ACTIONS[:mood_good]
      image_reply(pb, "https://pbs.twimg.com/profile_images/378800000440652970/7fb4db7088ad7b569ab96b00a3865990_400x400.jpeg")
      text_reply(pb, "That's great :)")
      text_reply(pb, "What's one thing about today that you can be happy about?")
    when ACTIONS[:mood_okay]
      text_reply(pb, "Glad that your day wasn't bad!")
      text_reply(pb, "What's one thing about today that you can be happy about?")
    when ACTIONS[:mood_bad]
      text_reply(pb, "That's too bad.. I hope that tomorrow will be a happier day for you.")
      text_reply(pb, "You can always find something to be grateful for – even during the worst moments!")
      text_reply(pb, "What's one thing about today, no matter how small, that you can be happy about?")
    end
  end

  # Confirms user whether he wants to really save his previous message as a log
  def handle_log msg
    button_reply(msg, "Confirm your answer of \"#{msg.text}\"?",
      [{type: 'postback', title: 'Yes', payload: ACTIONS[:submit_yes]},
      {type: 'postback', title: 'No', payload: ACTIONS[:submit_no]}])
  end

  # Accepts user's gratefulness post and asks for confirmation through postback
  def confirm_submit pb
    text_reply(pb, "Thanks for interacting with me.")
    text_reply(pb, "Please feel free to talk to me further as specified by the menu.")
    text_reply(pb, "Else, hope to see you again tomorrow! FYI, click on the menu icon and tap 'I'll create an entry now.' to make another entry.")
  end

  # After executing, returns to postback manager; user can type his/her answer again
  def unconfirm_submit pb
    text_reply(pb, "Retype your response, please.")
  end

  # Intro interaction
  def introduction pb
    text_reply(pb, "I'm Zenful Bot, a Facebook chatbot designed to remind you of all the great things in your life.")
    button_reply(pb,"Please tap 'Learn more' to learn more about how I work.",
      [{type: 'postback', title: 'Learn more', payload: ACTIONS[:learn_more]}])
  end

  # Part of intro sequence
  def learn_more pb
    text_reply(pb, "You can use me to record things about your day that you were grateful for.")
    text_reply(pb, "Please click on the menu on the bottom of the screen to see more options, such as why what I do can help you be happier over time.")
    button_reply(pb,"If you are ready to proceed, please tap 'Sign me up!'",
      [{type: 'postback', title: 'Sign me up!', payload: ACTIONS[:begin_routine]}])
  end
end