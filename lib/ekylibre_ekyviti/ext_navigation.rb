module EkylibreEkyviti
  class ExtNavigation
    def self.add_navigation_xml_to_existing_tree
      ext_navigation = ExtNavigation.new
      ext_navigation.build_new_tree
    end

    attr_reader :plugin_navigation_tree, :new_navigation_tree

    def initialize
      @plugin_navigation_tree = Ekylibre::Navigation::Tree
                                .load_file(plugin_navigation_file_path,
                                           :navigation,
                                           %i[part group item])
    end

    def build_new_tree
      @plugin_navigation_tree.children.each do |part|
        navigation_part = Ekylibre::Navigation.tree.get(part.name)
        part.children.each do |group|
          navigation_group = navigation_part.get(group.name)

          group.children.each do |item|
            navigation_item = navigation_group.get(item.name)
            unless navigation_item
              navigation_group.add_child(item)
              navigation_item = navigation_group.children.last
            end
            item.pages.each do |page|
              navigation_item.add_page(page)
            end
          end
        end
      end

      @new_navigation_tree = Ekylibre::Navigation.tree

      @new_navigation_tree.rebuild_index!

      @new_navigation_tree
    end

    private

    def plugin_navigation_file_path
      EkylibreEkyviti::Engine.root.join('config', 'navigation.xml')
    end
  end
end
