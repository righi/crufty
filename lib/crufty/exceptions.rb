module Crufty
  class CodeExpired < StandardError
    attr_reader :best_by, :expires

    def initialize(context)
      @best_by = context.best_by
      @expires = context.expires

      set_backtrace(context.backtrace)
    end
  end
end