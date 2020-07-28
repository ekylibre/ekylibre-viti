module Lexicon
  class << self
    # @return [Maybe<Semantic::Version>]
    def enabled_version
      if version_table_present?
        Some(
          Semantic::Version.new(
            database
              .query('SELECT version FROM lexicon.version LIMIT 1')
              .to_a.first
              .fetch('version')
          )
        )
      else
        None()
      end
    end

    # @return [Boolean]
    def enabled?
      enabled_version.is_some?
    end

    def execute_post_processing
      return unless post_processing_script.exist?

      db = Rails.application.config.database_configuration[Rails.env].with_indifferent_access
      db_url = Shellwords.escape("postgresql://#{db[:username]}:#{db[:password]}@#{db[:host]}:#{db[:port] || 5432}/#{db[:database]}")
      (Ekylibre::Tenant.list + %w[public]).each do |tenant|
        puts "== Post-processing for #{tenant} tenant : migrating ==".ljust(79, '=').cyan
        start = Time.now
        `echo 'SET SEARCH_PATH TO "#{tenant}";' | cat - #{post_processing_script.to_s} | psql --dbname=#{db_url}`
        puts "== Post-processing for #{tenant} tenant : migrated (#{(Time.now - start).round(4)}s) ==".ljust(79, '=').cyan
      end
    end

    private

      def database
        Ekylibre::Record::Base.connection.raw_connection
      end

      def post_processing_script
        Rails.root.join('db', 'lexicon', 'post_processing.sql')
      end

      def version_table_present?
        database
          .query("SELECT count(*) AS presence FROM information_schema.tables WHERE table_schema = 'lexicon' AND table_name = 'version'")
          .to_a.first
          .fetch('presence').to_i.positive?
      end
  end
end
