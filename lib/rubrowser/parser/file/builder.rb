module Rubrowser
  module Parser
    class File
      # This class is a workaround for this behaviour
      # https://github.com/whitequark/parser/commit/95401a20e8f4532e32f6361da3918ac8e4bd18c7
      # the snippet that is using this class in File is copied from:
      # https://github.com/eapache/starscope/pull/166/files
      class Builder < ::Parser::Builders::Default
        def string_value(token)
          value(token)
        end
      end
    end
  end
end
