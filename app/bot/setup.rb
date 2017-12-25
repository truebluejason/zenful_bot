require "facebook/messenger"
include Facebook::Messenger

class SetUp
	def self.enable
    self.set_intro
    self.set_menu
	end

  # Sets up "Get Started" button
  def self.set_intro
    Facebook::Messenger::Profile.set({
      get_started: {
        payload: ACTIONS[:start]
      }
    }, access_token: ENV['ACCESS_TOKEN'])
  end

  # Sets up Menu
  def self.set_menu
    Facebook::Messenger::Profile.set({
        persistent_menu: [{
            locale: 'default',
            composer_input_disabled: false,
            call_to_actions: [
              {
                  type: 'nested',
                    title: 'Show me my past responses!',
                    call_to_actions: [
                      {
                        type: 'postback',
                        title: 'A specific response.',
                        payload: ACTIONS[:menu_show_specific]
                      },
                      {
                        type: 'postback',
                        title: 'All responses.',
                        payload: ACTIONS[:menu_show_all]
                      }
                    ]
                },
                {
                  type: 'postback',
                    title: 'How do exactly do you help me?',
                    payload: ACTIONS[:menu_reason]
                },
                {
                    type: 'postback',
                    title: "I'll tell you about today now.",
                    payload: ACTIONS[:menu_act]
                }
            ]
        }]
    }, access_token: ENV['ACCESS_TOKEN'])
  end
end