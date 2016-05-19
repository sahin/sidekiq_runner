module SidekiqRunner
  module SidekiqPerform
    extend ActiveSupport::Concern

    module ClassMethods
      def method_missing(method_sym, *args)
        method_name = method_sym.to_s
        if method_name.end_with? '_async'
          queue = sidekiq_options_hash['queue']
          Sidekiq::Client.enqueue_to(queue, self, method_name, args)
        else
          super
        end
      end
    end


    def perform(method_name, args)
      method(method_name).call(args)
    end

    def perform_safe(method_name, args)
      unless File.directory?(Rails.root)
        fail 'Non exist Workers app folder. The release folder deleted. Please retry the job'
        # Please kill the workers and start again. Please check https://www.pivotaltracker.com/story/show/55338376 for more information'
      end

      if method_name && respond_to?(method_name)
        logger_info("Starting work for #{self.class}.#{method_name}")
        method(method_name).call(args)
      else
        fail "Method #{method_name} doesnt exists in class #{self.class.name.to_s}. No job is performed"
      end
    end
  end
end
