module EkylibreEkyviti
  module Lexicon
    class << self

      def execute_post_processing
        return unless post_processing_script.exist?

        db = Rails.application.config.database_configuration[Rails.env].with_indifferent_access
        db_url = Shellwords.escape("postgresql://#{db[:username]}:#{db[:password]}@#{db[:host]}:#{db[:port] || 5432}/#{db[:database]}")
        (Ekylibre::Tenant.list + %w[public]).each do |tenant|
          puts "== Post-processing for #{tenant} tenant : migrating ==".ljust(79, '=').cyan
          start = Time.zone.now
          `echo 'SET SEARCH_PATH TO "#{tenant}";' | cat - #{post_processing_script} | psql --dbname=#{db_url}`
          puts "== Post-processing for #{tenant} tenant : migrated (#{(Time.zone.now - start).round(4)}s) ==".ljust(79, '=').cyan
        end
      end

      private

      def post_processing_script
        EkylibreEkyviti::Engine.root.join('db', 'lexicon', 'post_processing.sql')
      end
    end
  end
end
