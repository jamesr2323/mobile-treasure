MobileScavenger::App.controller do  

    get '/sms' do
        sender = params[:From]
        body = params[:Body]

        instruction = body[0].upcase

        #If this is a message from the master, and it has an instruction then obey the instruction. Otherwise treat it like any other message
        if sender == ENV['MASTER_NUMBER'] && ["A","R","N","M","T"].include?(instruction)
            puts instruction
            hunter_id = body.split(' ').first[1..-1]
            content = body.split(' ')[1..-1].join(' ')
            if hunter = Hunter.find_by(id: hunter_id)
                # A = Advance
                if instruction == "A"
                    hunter.advance
                elsif instruction == "R" #R = repeat
                    hunter.give_clue
                elsif instruction == "N" #N = No
                    hunter.tell_no
                elsif instruction == "M" #M = Move
                    hunter.move_to(content)
                elsif instruction == "T" #T = Text them
                    hunter.message(content)
                end
            end
        else
            if hunter = Hunter.find_by(phone: sender)
                hunter.forward_message(body)
            end
        end
    end

end