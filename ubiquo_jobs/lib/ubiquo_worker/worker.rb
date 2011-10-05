module UbiquoWorker

  class Worker
    attr_accessor :name, :sleep_time, :sleep_interval, :shutdown

    def initialize(name, options = {})
      raise ArgumentError, "A worker name is required" if name.blank?
      self.name = name
      self.sleep_time = options[:sleep_time]
      self.sleep_interval = options[:sleep_interval] || 1.0
      self.shutdown = false
    end

    # This method will start executing the planified jobs.
    # If no job is available, the worker will sleep for sleep_time sec.
    def run!
      daemon_handle_signals
      while (!shutdown) do
        job = UbiquoJobs.manager.get(name)
        if job
          puts "#{Time.now} [#{name}] - executing job #{job.id}"
          job.run!
        else
          puts "#{Time.now} [#{name}] - no job available"
          wait
        end
      end
    end

    private

    def daemon_handle_signals
      Signal.trap("TERM") do
        puts "Caught TERM signal, terminating ..."
        self.shutdown = true
      end
    end

    def wait
      time_slept = 0
      while time_slept < self.sleep_time
        break if shutdown
        sleep sleep_interval
        time_slept = time_slept + sleep_interval
      end
    end

  end
end


