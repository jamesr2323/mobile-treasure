MobileScavenger::App.controller do  

    post '/twiml/play', :csrf_protection => false  do
        Twilio::TwiML::Response.new do |r|
            r.Play params[:audio_url]
        end.text
    end

end