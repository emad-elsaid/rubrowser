module Rubrowser
  class Channel < LiteCable::Channel::Base
    identifier :classes

    def subscribed
      stream_from "classes"
    end
  end
end
