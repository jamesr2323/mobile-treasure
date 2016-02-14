class Hunter < ActiveRecord::Base

    belongs_to :stage

    validates_presence_of :name, :phone, :stage_id

    after_initialize :init

    def init
        self.stage = Stage.first_in_order if self.new_record?
        puts "initializing"
    end

    def client
        Twilio::REST::Client.new ENV['TWILIO_SID'], ENV['TWILIO_AUTH_TOKEN']
    end

    def advance
        if self.stage.next_stage
            self.stage = self.stage.next_stage
            save
            give_clue
        end
    end

    def give_clue
        if self.stage.clue_type == 'sms'
            self.message(self.stage.content)
        elsif self.stage.clue_type == 'audio'
            self.play_audio(self.stage.content)
        end
    end

    def tell_no
        if ENV['INCORRECT_AUDIO_URL']
            client.account.calls.create(
              :from => ENV['FROM_NUMBER'], 
              :to => self.phone, 
              # Fetch instructions from this URL when the call connects
              :url => "http://#{ENV['APPLICATION_URL']}/twiml/play?audio_url=#{URI.escape(ENV['INCORRECT_AUDIO_URL'])}"
            )
        else
            client.account.messages.create(
              :from => ENV['FROM_NUMBER'],
              :to => self.phone,
              :body => "Sorry - try again"
            )
        end
    end

    def message(message)
        client.account.messages.create(
            :from => ENV['FROM_NUMBER'],
            :to => self.phone,
            :body => "#{message}"
          )
    end

    def play_audio(audio_url)
        client.account.calls.create(
          :from => ENV['FROM_NUMBER'], 
          :to => self.phone, 
          # Fetch instructions from this URL when the call connects
          :url => "http://#{ENV['APPLICATION_URL']}/twiml/play?audio_url=#{URI.escape(audio_url)}"
        )
    end

    def forward_message(message)
        client.account.messages.create(
            :from => ENV['FROM_NUMBER'],
            :to => ENV['MASTER_NUMBER'],
            :body => "#{id}: #{message}"
          )
    end

end