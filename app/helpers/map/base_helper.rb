# coding: utf-8

module Map
  module BaseHelper
    def resource
      return send(controller_name.singularize) if respond_to?(controller_name.singularize)

      instance_variable_get('@' + controller_name.singularize)
    end

    def resource_model
      controller_name.classify.constantize
    end

    def user_preference_value(name, default = nil)
      preference = current_user.preferences.find_by(name: name)
      preference ? preference.value : default
    end

    def collection
      instance_variable_get('@' + controller_name)
    end

    def drawer(*_args, &block)
      # ???: what are *args used for ?
      content_for(:drawer) do
        content_tag(:div, class: 'drawer', id: 'drawer', &block)
      end
    end

    def drawer_header(text)
      content_tag(:div, class: 'drawer-header') do
        # content_tag(:a, class: 'close', data: { dismiss: 'drawer' }) do
        #   content_tag(:span, '×')
        # end +
        content_tag(:h4, text, class: 'drawer-title')
      end
    end

    def active_url?(url_options)
      controller_path == url_options[:controller].to_s &&
        action_name == url_options[:action].to_s
    end

    def link_or_not_to(text, url_options = {}, html_options = {})
      url_options[:controller] ||= controller_path
      url_options[:action] ||= :index
      if active_url?(url_options)
        html_options[:disabled] = true
        html_options[:class] ||= ''
        html_options[:class] << ' active'
      end
      link_to(text, url_options, html_options)
    end

    # Build a JSON for a data-tour parameter and put it on <body> element
    def tour(name, _options = {})
      preference = current_user.preference("interface.tours.#{name}.finished", false, :boolean)
      return if preference.value

      object = {}
      object[:defaults] ||= {}
      object[:defaults][:classes] ||= 'shepherd-theme-arrows'
      object[:defaults][:show_cancel_link] = true unless object[:defaults].key?(:show_cancel_link)
      unless object[:defaults][:buttons]
        buttons = []
        buttons << {
          text: :next.tl,
          classes: 'btn btn-primary',
          action: 'next'
        }
        object[:defaults][:buttons] = buttons
      end
      lister = Ekylibre::Support::Lister.new(:step)
      yield lister
      return nil unless lister.any?

      steps = lister.steps.map do |step|
        id = step.args.first
        on = (step.options[:on] || 'center').to_s
        if reading_ltr?
          if on =~ /right/
            on.gsub!('right', 'left')
          else
            on.gsub!('left', 'right')
          end
        end
        attributes = {
          id: id,
          title: "tours.#{name}.#{id}.title".tl,
          text: "tours.#{name}.#{id}.content".tl,
          attachTo: {
            element: step.options[:element] || '#' + id.to_s,
            on: on.tr('_', ' ')
          }
        }
        if step == lister.steps.last
          attributes[:buttons] = [{ text: :finished.tl, classes: 'btn btn-primary', action: 'next' }]
        end
        attributes
      end
      object[:name] = name
      object[:url] = finish_backend_tour_path(id: name)
      object[:steps] = steps
      content_for(:tour, object.jsonize_keys.to_json)
    end

    def map_config(options = {})
      {
        box: {
          width: '100%',
          height: '100%'
        }, backgrounds:
        [
          [
            'MapBox', {
              id: 'mapbox.satellite',
              accessToken: ENV['MAPBOX_API_KEY'],
              maxZoom: 23
            }
          ]
        ], defaultCenter: {
          lat: 46.74738913515841,
          lng: 2.493896484375
        },
        cut: {
          cycling: 12,
          panel: {
            animatedHelper: image_url('animations/cut.gif'),
            subtitleProperty: :set_timeline_to_correct_date.tl
          }
        }
      }.merge options
    end
  end
end
