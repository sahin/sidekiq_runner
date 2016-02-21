module SidekiqRunner
  class Runner

    # it adds to sidekiq queue directly
    def self.enqueue(class_name, method_name, args = {})
      queue = get_queue_name(class_name)
      enqueue_to(queue, class_name, method_name, args)
    end

    def self.run(class_name, method_name, args = {})
      queue = get_queue_name(class_name)
      run_in_queue(queue, class_name, method_name, args)
    end

    # it adds to sidekiq queue directly
    def self.enqueue_to(queue, class_name, method_name, args = {})
      Sidekiq::Client.enqueue_to(queue, class_name.constantize, method_name, args)
    end

    # it checks production, if production it adds in queue otherwise runs the method
    def self.run_in_queue(queue, class_name, method_name, args = {})

      run_as_background_job = Rails.env.production? ? true : false

      if run_as_background_job
        fail 'Non exist Workers app folder. The release folder deleted.'\
             'Please kill the workers and start again.' unless File.directory?(Rails.root)

        begin
          enqueue_to(queue, class_name, method_name, args)
          Sidekiq::Logging.logger.info "#{class_name}.#{method_name} Sidekiq job added with args #{args.inspect}"
        rescue => ex
          Sidekiq::Logging.logger.info ex
        end
      else
        fail "#{method_name} doesnt exists #{class_name}" unless class_name.constantize.new.respond_to?(method_name.to_sym)

        Sidekiq::Logging.logger.info "Running #{method_name} with args #{args.to_s}"
        obj = class_name.constantize.new
        args.empty? ? obj.send(method_name) : obj.send(method_name, args)
      end

    end

    def self.get_queue_name(class_name)
      class_name.constantize.sidekiq_options_hash['queue']
    end
  end
end
