require 'date'

module Crufty
  class Context
    attr_reader :best_by, :expires, :backtrace, :invoked_at

    def initialize(best_by, expires, backtrace=nil)
      if datetimeish?(best_by) && datetimeish?(expires)
        @invoked_at = DateTime.now
      elsif timeish?(best_by) && timeish?(expires)
        @invoked_at = Time.now
      else
        raise ArgumentError, "Unexpected time params: #{best_by.class} and #{expires.class}"
      end
      
      @best_by = best_by
      @expires = expires
      @backtrace = backtrace
    end

    def state
      @state ||= (expired? ? :expired : (stale? ? :stale : :fresh))
    end

    def fresh?
      !stale? && !expired?
    end

    def stale?
      if @best_by.nil?
        true
      else
        @invoked_at >= @best_by
      end
    end

    def expired?
      if @expires.nil?
        false
      else
        @invoked_at >= @expires
      end
    end

    private

      def datetimeish?(time)
        time.nil? || time.is_a?(DateTime)
      end

      def timeish?(time)
        time.nil? || time.is_a?(Time)
      end
  end
end