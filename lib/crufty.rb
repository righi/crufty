require "crufty/version"
require "crufty/context"
require "crufty/exceptions"
require "logger"

module Crufty
  class << self
    attr_accessor :logger, :stale_handler, :expired_handler
    attr_writer :env

    def env
      @env ||= ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"
    end

    def on_stale(&block)
      self.stale_handler = block
    end

    def on_expired(&block)
      self.expired_handler = block
    end
  end

  DEFAULT_ON_STALE_HANDLER = proc do |ctx|
    stale_detail = (ctx.best_by.nil?) ? "Crufty code" : "Code went crufty at #{ctx.best_by} and"
    expires_detail = (ctx.expires.nil?) ? "should be removed" : "will stop working at #{ctx.expires}"
    Crufty.logger.warn("#{stale_detail} #{expires_detail}: #{ctx.backtrace[0]}")
  end

  DEFAULT_ON_EXPIRED_HANDLER = proc do |ctx|
    raise ::Crufty::CodeExpired.new(ctx), "Crufty code expired at #{ctx.expires}", ctx.backtrace
  end

  if defined?(Rails) && Rails.logger
    self.logger = Rails.logger
  else
    self.logger = Logger.new($stdout)
  end

  self.stale_handler = DEFAULT_ON_STALE_HANDLER
  self.expired_handler = DEFAULT_ON_EXPIRED_HANDLER

  module Methods
    def crufty(warn_after = nil, error_after = nil, best_by: nil, expires: nil)
      raise ArgumentError if (warn_after && best_by) || (error_after && expires)

      best_by = warn_after || best_by
      expires = error_after || expires

      ctx = ::Crufty::Context.new(best_by, expires, caller)

      if ctx.state == :expired
        Crufty.expired_handler.call(ctx)
      elsif ctx.state == :stale
        Crufty.stale_handler.call(ctx)
        yield
      else
        yield
      end
    end
  end
end

Object.send :include, Crufty::Methods
