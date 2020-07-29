# frozen_string_literal: true
module EkylibreEkyviti
  class DevInstallGenerator < Rails::Generators::Base
    source_root File.expand_path('templates', __dir__)

    def copy_capistrano_files
      directory 'config/capistrano/deploy', 'config/deploy'
      copy_file 'config/capistrano/deploy.rb', 'config/deploy.rb'
      copy_file 'config/capistrano/Capfile', "Capfile"
    end
  end
end
