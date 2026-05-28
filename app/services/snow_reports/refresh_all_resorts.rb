module SnowReports
  class RefreshAllResorts
    def initialize(refresh_resort: RefreshResort.new)
      @refresh_resort = refresh_resort
    end

    def call(scope: Resort.order(:name))
      run = SnowRefreshRun.create!(
        started_at: Time.current,
        status: "running"
      )

      scope.find_each do |resort|
        run.increment!(:resorts_attempted)

        observation = @refresh_resort.call(resort: resort)

        if observation.present?
          run.increment!(:observations_created)
        end
      rescue StandardError => error
        run.increment!(:error_count)
        Rails.logger.warn(
          "Snow refresh failed for #{resort.name}: #{error.class} #{error.message}"
        )
      end

      final_status = run.error_count.positive? ? "partial" : "succeeded"

      run.update!(
        status: final_status,
        finished_at: Time.current
      )

      run
    rescue StandardError => error
      run&.update!(
        status: "failed",
        finished_at: Time.current,
        notes: error.message
      )

      raise
    end
  end
end
