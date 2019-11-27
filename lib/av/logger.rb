module AV
  class << self
    def logger
      return Rails.logger if defined?(Rails) && Rails.logger

      @logger ||= Logger.new($stderr)
    end
  end
end
