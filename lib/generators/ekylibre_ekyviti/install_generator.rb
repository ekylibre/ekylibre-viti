# frozen_string_literal: true

module EkylibreEkyviti
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def copy_capistrano_files
      directory 'config/capistrano/deploy', 'config/deploy'
      copy_file 'config/capistrano/deploy.rb', 'config/deploy.rb'
      copy_file 'config/capistrano/Capfile', "Capfile"
    end

    def copy_exchanger_template_file
      copy_file '../../../../config/locales/fra/exchangers/ekylibre_cvi_csv.csv', 'config/locales/fra/exchangers/ekylibre_cvi_csv.csv'
    end

    def update_i18n_js
      rake('i18n:js:export')
    end
  end
end
