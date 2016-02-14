class Stage < ActiveRecord::Base

    has_many :hunters

    validates_presence_of :content
    validates_presence_of :clue_type

    class << self
        def first_in_order
            Stage.all.order(:order).first
        end
    end

    def send_clue

    end

    def next_stage
        Stage.where(%Q{"order" > ?},self.order).order(%Q{"order"}).first
    end

end