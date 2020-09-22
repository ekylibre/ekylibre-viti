module Form
  module ActivityFormConfigExt
    private
      def config
        [Rails.root.join('app/services/form/activity_form_config.yml'), EkylibreEkyviti::Engine.root.join('app/services/form/activity_form_config.yml')]
          .map{ |file| YAML.safe_load(File.read(file)) }
          .reduce({}, :merge!)
      end
  end
end
