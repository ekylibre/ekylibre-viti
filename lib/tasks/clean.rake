def hash_to_yaml(hash, depth=0)
  code = "\n"
  x = hash.to_a.sort{|a,b| a[0].to_s.gsub("_"," ").strip<=>b[0].to_s.gsub("_"," ").strip}
  x.each_index do |i|
    k, v = x[i][0], x[i][1]
    # code += "  "*depth+k.to_s+":"+(v.is_a?(Hash) ? "\n"+hash_to_yaml(v,depth+1) : " '"+v.gsub("'", "''")+"'\n") if v
    code += "  "*depth+k.to_s+":"+(v.is_a?(Hash) ? hash_to_yaml(v, depth+1) : " "+yaml_value(v))+(i == x.size-1 ? '' : "\n") if v
  end
  code
end

def yaml_to_hash(filename)
  hash = YAML::load(IO.read(filename).gsub(/^(\s*)no:(.*)$/, '\1__no_is_not__false__:\2'))
  return deep_symbolize_keys(hash)
end

def hash_sort_and_count(hash, depth=0)
  hash ||= {}
  code, count = "", 0
  for key, value in hash.sort{|a, b| a[0].to_s <=> b[0].to_s}
    if value.is_a? Hash
      scode, scount = hash_sort_and_count(value, depth+1)
      code += "  "*depth+key.to_s+":\n"+scode
      count += scount
    else
      code += "  "*depth+key.to_s+": "+yaml_value(value, depth+1)+"\n"
      count += 1
    end
  end
  return code, count
end


def hash_count(hash)
  count = 0
  for key, value in hash
    count += (value.is_a?(Hash) ? hash_count(value) : 1)
  end
  return count
end
  
def sort_yaml_file(filename, log=nil)
  yaml_file = Ekylibre::Application.root.join("config", "locales", ::I18n.locale.to_s, "#{filename}.yml")
  # translation = hash_to_yaml(yaml_to_hash(file)).strip
  translation, total = hash_sort_and_count(yaml_to_hash(yaml_file))
  File.open(yaml_file, "wb") do |file|
    file.write translation.strip
  end
  count = 0
  log.write "  - #{(filename.to_s+'.yml:').ljust(16)} #{(100*(total-count)/total).round.to_s.rjust(3)}% (#{total-count}/#{total})\n" if log
  return total
end

def deep_symbolize_keys(hash)
  hash.inject({}) { |result, (key, value)|
    value = deep_symbolize_keys(value) if value.is_a? Hash
    key = :no if key.to_s == "__no_is_not__false__"
    result[(key.to_sym rescue key) || key] = value
    result
  }
end


def yaml_value(value, depth=0)
  if value.is_a?(Array)
    "["+value.collect{|x| yaml_value(x)}.join(", ")+"]"
  elsif value.is_a?(Symbol)
    ":"+value.to_s
  elsif value.is_a?(Hash)
    hash_to_yaml(value, depth+1)
  elsif value.is_a?(Numeric)
    value.to_s
  else
    "'"+value.to_s.gsub("'", "''")+"'"
  end
end

def hash_diff(hash, ref, depth=0)
  hash ||= {}
  ref ||= {}
  keys = (ref.keys+hash.keys).uniq.sort{|a,b| a.to_s.gsub("_"," ").strip<=>b.to_s.gsub("_"," ").strip}
  code, count, total = "", 0, 0
  for key in keys
    h, r = hash[key], ref[key]
    # total += 1 unless r.is_a? Hash
    if r.is_a?(Hash) and (h.is_a?(Hash) or h.nil?)
      scode, scount, stotal = hash_diff(h, r, depth+1)
      code  += "  "*depth+key.to_s+":\n"+scode
      count += scount
      total += stotal
    elsif r and h.nil?
      code  += "  "*depth+"#>"+key.to_s+": "+yaml_value(r, depth+1)+"\n"
      count += 1
      total += 1
    elsif r and h and r.class == h.class
      code  += "  "*depth+key.to_s+": "+yaml_value(h, depth+1)+"\n"
      total += 1
    elsif r and h and r.class != h.class
      code  += "  "*depth+key.to_s+": "+(yaml_value(h, depth)+"\n").gsub(/\n/, " #! #{r.class.name} excepted (#{h.class.name+':'+h.inspect})\n")
      total += 1
    elsif h and r.nil?
      code  += "  "*depth+key.to_s+": "+(yaml_value(h, depth)+"\n").to_s.gsub(/\n/, " #!\n")
    elsif r.nil?
      code  += "  "*depth+key.to_s+": #!\n"
    end
  end  
  return code, count, total
end


def actions_in_file(path)
  actions = []
  File.open(path, "rb").each_line do |line|
    line = line.gsub(/(^\s*|\s*$)/,'')
    if line.match(/^\s*def\s+[a-z0-9\_]+\s*$/)
      actions << line.split(/def\s/)[1].gsub(/\s/,'') 
    elsif line.match(/^\s*dy(li|ta)[\s\(]+\:\w+/)
      dyxx = line.split(/[\s\(\)\,\:]+/)
      actions << dyxx[1]+'_'+dyxx[0]
    elsif line.match(/^\s*create_kame[\s\(]+\:\w+/)
      dyxx = line.split(/[\s\(\)\,\:]+/)
      actions << dyxx[1]+'_kame'
    elsif line.match(/^\s*manage_list[\s\(]+\:\w+/)
      prefix = line.split(/[\s\(\)\,\:]+/)[1].singularize
      actions << prefix+'_up'
      actions << prefix+'_down'
    elsif line.match(/^\s*manage[\s\(]+\:\w+/)
      prefix = line.split(/[\s\(\)\,\:]+/)[1].singularize
      actions << prefix+'_create'
      actions << prefix+'_update'
      actions << prefix+'_delete'
    end
  end
  return actions
end


namespace :clean do



  desc "Update models list file in lib/models.rb"
  task :models => :environment do
    
    Dir.glob(Ekylibre::Application.root.join("app", "models", "*.rb")).each { |file| require file }
    # models = Object.subclasses_of(ActiveRecord::Base).select{|x| not x.name.match('::')}.sort{|a,b| a.name <=> b.name}
    models = ActiveRecord::Base.subclasses.select{|x| not x.name.match('::')}.sort{|a,b| a.name <=> b.name}
    models_code = "  @@models = ["+models.collect{|m| ":"+m.name.underscore}.join(", ")+"]\n"
    
    symodels = models.collect{|x| x.name.underscore.to_sym}

    errors = 0
    models_file = Ekylibre::Application.root.join("lib", "models.rb")
    require models_file
    refs = Ekylibre.references
    refs_code = ""
    for model in models
      m = model.name.underscore.to_sym
      cols = []
      model.columns.sort{|a,b| a.name<=>b.name}.each do |column|
        c = column.name.to_sym
        if c.to_s.match(/_id$/)
          val = (refs[m].is_a?(Hash) ? refs[m][c] : nil)
          val = ((val.nil? or val.blank?) ? "''" : val.inspect)
          if c == :parent_id
            val = ":#{m}"
          elsif [:creator_id, :updater_id, :responsible_id].include? c
            val = ":user"
          elsif model.columns_hash.keys.include?(c.to_s[0..-4]+"_type")
            val = "\"#{c.to_s[0..-4]}_type\""
          elsif symodels.include? c.to_s[0..-4].to_sym
            val = ":#{c.to_s[0..-4]}"
          end
          errors += 1 if val == "''"
          cols << "      :#{c} => #{val}"
        end
      end
      refs_code += "\n    :#{m} => {\n"+cols.join(",\n")+"\n    },"
    end
    puts " - Models: #{errors} errors"
    refs_code = "  @@references = {"+refs_code[0..-2]+"\n  }\n"

    File.open(models_file, "wb") do |f|
      f.write("# Autogenerated from Ekylibre (`rake clean:models` or `rake clean`)\n")
      f.write("module Ekylibre\n")
      f.write("  mattr_reader :models, :references\n")
      f.write("  # List of all models\n")
      f.write(models_code)
      f.write("\n  # List of all references\n")
      f.write(refs_code)
      f.write("\n")
      f.write("end\n")
    end

  end


  desc "Look at bad and suspect views"
  task :views => :environment do

    views = []
    for controller_file in Dir.glob(Ekylibre::Application.root.join("app", "controllers", "*.rb")).sort
      source = ""
      File.open(controller_file, "rb") do |f|
        source = f.read
      end
      controller = controller_file.split(/[\\\/]+/)[-1].gsub('_controller.rb', '')
      for file in Dir.glob(Ekylibre::Application.root.join("app", "views", controller, "*.*")).sort
        action = file.split(/[\\\/]+/)[-1].split('.')[0]
        valid = false
        valid = true if not valid and source.match(/^\s*def\s+#{action}\s*$/)
        valid = true if not valid and action.match(/^_\w+_form$/) and (source.match(/^\s*def\s+#{action[1..-6]}_(upd|cre)ate\s*$/) or source.match(/^\s*manage\s*\:#{action[1..-6].pluralize}(\W|$)/))
        if action.match(/^_/) and not valid
          if source.match(/^[^\#]*(render|replace_html)[^\n]*partial[^\n]*#{action[1..-1]}/)
            valid = true 
          else
            for view in Dir.glob(Ekylibre::Application.root.join("app", "views", controller, "*.*"))
              File.open(view, "rb") do |f|
                view_source = f.read
                if view_source.match(/(render|replace_html)[^\n]*partial[^\n]*#{action[1..-1]}/)
                  valid = true
                  break
                end
              end
            end
          end
        end
        views << file.gsub(Ekylibre::Application.root.to_s, '.') unless valid
      end
    end
    puts " - Views: #{views.size} potentially bad views"
    for view in views
      puts "   #{view}"
    end
  end



  desc "Update and sort rights list"
  task :rights => :environment do
    new_right = '__not_used__'

    # Chargement des actions des controllers
    ref = {}
    Dir.glob(Ekylibre::Application.root.join("app", "controllers", "*_controller.rb")) do |x|
      controller_name = x.split("/")[-1].split("_controller")[0]
      ref[controller_name] = actions_in_file(x).sort
    end

    # Lecture du fichier existant
    rights = YAML.load_file(User.rights_file)

    # Expand actions
    for right, attributes in rights
      attributes['actions'].each_index do |index|
        unless attributes['actions'][index].match(/\:\:/)
          attributes['actions'][index] = attributes['controller'].to_s+"::"+attributes['actions'][index] 
        end
      end if attributes['actions'].is_a? Array
    end
    rights_list  = rights.keys.sort
    actions_list = rights.values.collect{|x| x["actions"]||[]}.flatten.uniq.sort

    # Ajout des nouvelles actions
    created = 0
    for controller, actions in ref
      for action in actions
        uniq_action = controller+"::"+action
        unless actions_list.include?(uniq_action)
          rights[new_right] ||= {}
          rights[new_right]["actions"] ||= []
          rights[new_right]["actions"] << uniq_action
          created += 1
        end
      end
    end

    # Commentaire des actions supprimées
    deleted = 0
    for right, attributes in rights
      attributes['actions'].each_index do |index|
        uniq_action = attributes["actions"][index]
        controller, action = uniq_action.split(/\W+/)[0..1]
        unless ref[controller].include?(action)
          attributes["actions"][index] += " # UNEXISTENT ACTION !!!"
          deleted += 1
        end
      end if attributes['actions'].is_a?(Array)
    end

    # Enregistrement du nouveau fichier
    code = ""
    for right in rights.keys.sort
      code += "# #{::I18n.translate('rights.'+right.to_s)}\n"
      code += "#{right}:\n"
      # code += "#{right}: # #{::I18n.translate('rights.'+right.to_s)}\n"
      controller, actions = rights[right]['controller'], []
      code += "  controller: #{controller}\n" unless controller.blank?
      if rights[right]["actions"].is_a?(Array)
        actions = rights[right]['actions'].sort
        actions = actions.collect{|x| x.match(/^#{controller}\:\:/) ? x.split('::')[1] : x}.sort unless controller.blank?
        line = "  actions: [#{actions.join(', ')}]"
        if line.length > 80 or line.match(/\#/)
        # if line.match(/\#/)
          code += "  actions:\n"
          for action in actions
            code += "  - #{action}\n"
          end
        else
          code += line+"\n"
        end
      end
    end
    File.open(User.rights_file, "wb") do |file|
      file.write code
    end

    puts " - Rights: #{deleted} deletable actions, #{created} created actions"
  end


  desc "Compact translations"
  task :loc => :environment do

    locale = ::I18n.locale = :arb # ::I18n.default_locale
    #locale_dir = Ekylibre::Application.root.join("config", "locales", locale.to_s)
    locale_dir = Ekylibre::Application.root.join("lc", locale.to_s)
    #locdir = Ekylibre::Application.root.join("locales", locale.to_s)
    locdir = Ekylibre::Application.root.join("lcx", locale.to_s)
    #locdir = Ekylibre::Application.root.join("config", "locales", locale.to_s)
    FileUtils.makedirs(locdir)

    mh = HashWithIndifferentAccess.new
    puts locale.inspect
    for reference_path in Dir.glob(locale_dir.join("*.yml")).sort
      next if reference_path.match(/accounting/)
      mh.deep_merge!(yaml_to_hash(reference_path))
    end
    controllers = [:application, :authentication, :management, :accountancy, :relations, :production, :company, :help].sort{|a,b| a.to_s<=>b.to_s}
    mh = mh[locale]
    # puts mh.keys.inspect
    translation  = "#{locale}:\n"
    translation += "  actions:\n"
    for controller in controllers
      translation += "    #{controller}:\n"
      for action, attributes in (mh[:views][controller]||{}).select{|a,b| !a.match(/^_/) and b.is_a? Hash}.sort
        # raise Exception.new([controller, action, attributes].inspect) unless attributes.is_a? Hash
        next unless attributes.is_a? Hash
        translation += "      #{action}: #{yaml_value(attributes[:title])}\n"
      end
    end

    translation += "  controllers:\n"
    for controller in controllers
      translation += "    #{controller}: #{yaml_value(mh[:controllers][controller][:title])}\n"
    end

    labels = []
    for controller in controllers
      for action, attributes in (mh[:views][controller]||{}).select{|a,b| b.is_a? Hash}
        for attr, value in attributes.delete_if{|k,v| k.to_s == "title"}
          labels << [attr, (value.is_a?(String) ? value.strip : value), "view #{controller}##{action}"]
        end
      end
      for mode in [:controllers, :helpers]
        for attr, value in (mh[mode][controller]||{}).select{|a,b| b.is_a? Hash}
          labels << [attr, (value.is_a?(String) ? value.strip : value), "#{mode.to_s.singularize} #{controller}##{action}"] unless attr.to_s == "title"
        end
      end
    end
    labels += mh[:general].to_a
    # labels << ["parameters-parameters", mh[:parameters]]
    labels << ["menu", mh[:views][:shared][:_menu]]
    labels << ["page_title", mh[:helpers][:application][:title]]
    labels << ["page_title_by_default", mh[:helpers][:application][:default_title]]
    stata = {}
    for key, value in labels
      stata[key] ||= {}
      stata[key][value] ||= 0
      stata[key][value] += 1
    end
    #puts stata.inspect
    for a in labels
      a[2] = nil if stata[a[0]].keys.size <= 1
    end
    translation += "  labels:\n"
    warnings = 0
    translation += labels.uniq.sort{|a,b| a[0]<=>b[0]}.collect do |k,v,c| 
      line = "    #{k}: #{yaml_value(v, 2)}\n"
      if c.is_a?(String) and stata[k].keys.size>1
        line = line.split(/\n/).collect{|l| l.ljust(80)+"# in #{c}\n"}.join 
        warnings += 1
      elsif stata[k].keys.size == 1 and stata[k].to_a[0][1]>1
        line = line.split(/\n/).collect{|l| l+" ##{stata[k].to_a[0][1]}\n"}.join
      end
      line
    end.join
    puts ">> Labels: #{labels.uniq.size} couples, #{labels.collect{|x| x[0]}.uniq.size} uniq keys, #{labels.collect{|x| x[1]}.uniq.size} uniq values, #{warnings} warnings"

    translation += "  notifications:"+hash_to_yaml(mh[:notifications], 2)+"\n"

    translation += "  parameters:"+hash_to_yaml(mh[:parameters], 2)+"\n"
    
    File.open(locdir.join("action.yml"), "wb") do |file|
      file.write translation
    end

    ###########   M O D E L S   ############
    translation  = "#{locale}:\n"

    translation += "  activerecord:"

    attributes = []
    for model, attrs in mh[:activerecord][:attributes]
      for attr, trans in attrs
        attributes << [attr, trans, model]
      end if attrs.is_a? Enumerable
    end
    stata = {}
    for key, value, model in attributes
      stata[key] ||= {}
      stata[key][value] ||= 0
      stata[key][value] += 1
    end
    override = {}
    stata.select{|k, v| v.keys.size > 1}.each{|k,v| override[k] = v.sort{|a, b| a[1]<=>b[1]}[-1][0]}
    # puts override.inspect
    renew, todel = {}, []
    for k, v, m in attributes
      next if override[k].nil? or override[k] == v
      renew[m] ||= {}
      renew[m][k] = v
      todel << [k, v]
    end
    for a, b in todel
      attributes.delete_if{|k, v, m| k==a and v==b}
    end
    # puts renew.inspect
    translation += "\n    attributes:\n"
    for model, attrs in renew
      translation += "      #{model}:\n"
      for attr, trans in attrs
        translation += "        #{attr}: #{yaml_value(trans, 5)}\n"
      end
    end
    attributes = attributes.collect{|x| x[0..1]}

    translation += "\n    errors:"+hash_to_yaml(mh[:activerecord][:errors], 3)

    translation += "\n    models:\n"
    models = []
    for model, trans in mh[:activerecord][:models]
      models << [model, trans]
    end
    translation += models.uniq.sort{|a,b| a[0]<=>b[0]}.collect{|k,v| "      #{k}: #{yaml_value(v, 3)}\n"}.join

    # All attributes
    translation += "  attributes:\n"
    translation += attributes.uniq.sort{|a,b| a[0]<=>b[0]}.collect{|k,v,m| "    #{k}: #{yaml_value(v, 3)}\n"}.join
    puts ">> Attributes: #{attributes.uniq.size} couples, #{attributes.collect{|x| x[0]}.uniq.size} uniq keys, #{attributes.collect{|x| x[1]}.uniq.size} uniq values"

    translation += "  models:"+hash_to_yaml(mh[:models], 2)

    File.open(locdir.join("models.yml"), "wb") do |file|
      file.write translation
    end

    ##############   S U P P O R T   #################
    translation  = "#{locale}:\n"

    for support in [:date, :datetime, :dyta, :kame, :number, :support, :time]
      translation += "  #{support}:"+hash_to_yaml(mh[support], 2)+"\n"
    end

    File.open(locdir.join("support.yml"), "wb") do |file|
      file.write translation
    end

    for file in [:countries, :languages, :rights] # , :accounting]
      filename = "#{file}.yml"
      FileUtils.copy_file locale_dir.join(filename), locdir.join(filename)
    end
  end


  desc "Update and sort translation files"
  task :locales => :environment do
    log = File.open(Ekylibre::Application.root.join("log", "clean.locales.log"), "wb")

    # Load of actions
    all_actions = {}
    for right, attributes in YAML.load_file(User.rights_file)
      for full_action in attributes['actions']
        controller, action = (full_action.match(/\:\:/) ? full_action.split(/\W+/)[0..1] : [attributes['controller'].to_s, full_action])
        all_actions[controller] ||= []
        all_actions[controller] << action unless action.match /dy(li|ta)|delete|kame/
      end if attributes['actions'].is_a? Array
    end
    useful_actions = all_actions.dup
    useful_actions.delete("authentication")
    useful_actions.delete("help")

    locale = ::I18n.locale = ::I18n.default_locale
    locale_dir = Ekylibre::Application.root.join("config", "locales", locale.to_s)
    FileUtils.makedirs(locale_dir) unless File.exist?(locale_dir)
    for directory in ["help", "prints", "profiles"]
      FileUtils.makedirs(locale_dir.join(directory)) unless File.exist?(locale_dir.join(directory))
    end
    log.write("Locale #{::I18n.locale_label}:\n")


    untranslated = to_translate = translated = 0
    warnings = []
    acount = atotal = 0

    translation  = "#{locale}:\n"
    
    # Actions
    translation += "  actions:\n"
    for controller_file in Dir[Ekylibre::Application.root.join("app", "controllers", "*.rb")].sort
      controller_name = controller_file.split("/")[-1].split("_controller")[0]
      actions = actions_in_file(controller_file).sort
      translation += "    #{controller_name}:\n"
      existing_actions = ::I18n.translate("actions.#{controller_name}").stringify_keys.keys rescue []
      # for action_name in (actions.delete_if{|a| a.to_s.match(/_delete$/)}|existing_actions).sort
      for action_name in (actions|existing_actions).sort
        name = ::I18n.hardtranslate("actions.#{controller_name}.#{action_name}")
        to_translate += 1 
        if actions.include?(action_name)
          # to_translate += 1 
          untranslated += 1 if name.blank?
        end
        translation += "      #{'#>' if name.blank?}#{action_name}: "+yaml_value(name.blank? ? action_name.humanize : name, 3)
        translation += " #!" unless actions.include?(action_name)
        translation += "\n"
      end
    end

    # Controllers
    translation += "  controllers:\n"
    for controller_file in Dir[Ekylibre::Application.root.join("app", "controllers", "*.rb")].sort
      controller_name = controller_file.split(/[\\\/]+/)[-1].gsub('_controller.rb', '')
      name = ::I18n.hardtranslate("controllers.#{controller_name}")
      untranslated += 1 if name.blank?
      to_translate += 1
      translation += "    #{'#>' if name.blank?}#{controller_name}: "+yaml_value(name.blank? ? controller_name.humanize : name, 2)+"\n"
    end

    # Errors
    to_translate += hash_count(::I18n.translate("errors"))
    translation += "  errors:"+hash_to_yaml(::I18n.translate("errors"), 2)+"\n"

    # Labels
    to_translate += hash_count(::I18n.translate("labels"))
    translation += "  labels:"+hash_to_yaml(::I18n.translate("labels"), 2)+"\n"

    # Notifications
    translation += "  notifications:\n"
    notifications = ::I18n.t("notifications")
    deleted_notifs = ::I18n.t("notifications").keys
    for controller in Dir[Ekylibre::Application.root.join("app", "controllers", "*.rb")]
      File.open(controller, "rb").each_line do |line|
        if line.match(/([\s\W]+|^)notify\(\s*\:\w+/)
          key = line.split(/notify\(\s*\:/)[1].split(/\W/)[0]
          deleted_notifs.delete(key.to_sym)
          notifications[key.to_sym] = "" if notifications[key.to_sym].nil? or (notifications[key.to_sym].is_a? String and notifications[key.to_sym].match(/\(\(\(/))
        end
      end
    end
    to_translate += hash_count(notifications) # .keys.size
    for key, trans in notifications.sort{|a,b| a[0].to_s<=>b[0].to_s}
      line = "    "
      if trans.blank?
        untranslated += 1 
        line += "#>"
      end
      line += "#{key}: "+yaml_value((trans.blank? ? key.to_s.humanize : trans), 2)
      line.gsub!(/$/, " #!") if deleted_notifs.include?(key)
      translation += line+"\n"
    end
    warnings << "#{deleted_notifs.size} bad notifications" if deleted_notifs.size > 0

    # Preferences
    to_translate += hash_count(::I18n.translate("preferences"))
    translation += "  preferences:"+hash_to_yaml(::I18n.translate("preferences"), 2)

    File.open(locale_dir.join("action.yml"), "wb") do |file|
      file.write(translation)
    end
    total = to_translate
    log.write "  - #{'action.yml:'.ljust(16)} #{(100*(total-untranslated)/total).round.to_s.rjust(3)}% (#{total-untranslated}/#{total}) #{warnings.to_sentence}\n"
    atotal += to_translate
    acount += total-untranslated
    

    count = sort_yaml_file :countries, log
    atotal += count
    acount += count

    count = sort_yaml_file :languages, log
    atotal += count
    acount += count

    # Models
    untranslated = 0
    to_translate = 0
    warnings = []
    models = {}
    attributes = {}
    ::I18n.translate("attributes").collect{|k, v| attributes[k.to_s] = [v, :unused]}
    ::I18n.translate("activerecord.models").collect{|k, v| models[k.to_s] = [v, :unused]}
    ::I18n.translate("models").collect{|k, v| models[k.to_s] ||= []; models[k.to_s][2] = v}
    models_files = Dir[Ekylibre::Application.root.join("app", "models", "*.rb")].collect{|m| m.split(/[\\\/\.]+/)[-2]}.sort
    for model_file in models_files
      model_name = model_file.sub(/\.rb$/,'')
      model = model_name.camelize.constantize
      if model < ActiveRecord::Base && !model.abstract_class?
        if models[model_name]
          models[model_name][1] = :used
        else
          models[model_name] = [model_name.humanize, :undefined]
        end
        for column in model.columns.collect{|c| c.name.to_s}
          if attributes[column]
            attributes[column][1] = :used
          else
            attributes[column] = [column.humanize, :undefined]
          end
        end
        for column in model.instance_methods
          attributes[column][1] = :used if attributes[column]
        end
      end
    end
    for k, v in models
      to_translate += 1 # if v[1]!=:unused
      untranslated += 1 if v[1]==:undefined
    end
    for k, v in attributes
      to_translate += 1 # if v[1]!=:unused
      untranslated += 1 if v[1]==:undefined
    end

    translation  = locale.to_s+":\n"
    translation += "  activerecord:\n"
    to_translate += hash_count(::I18n.translate("activerecord.attributes"))
    translation += "    attributes:"+hash_to_yaml(::I18n.translate("activerecord.attributes"), 3)+"\n"
    to_translate += hash_count(::I18n.translate("activerecord.errors"))
    translation += "    errors:"+hash_to_yaml(::I18n.translate("activerecord.errors"), 3)+"\n"
    translation += "    models:\n"
    for model, definition in models.sort
      translation += "      "
      translation += "#>"  if definition[1] == :undefined
      translation += "#{model}: "+yaml_value(definition[0])
      translation += " #!" if definition[1] == :unused      
      translation += "\n"
    end
    translation += "  attributes:\n"
    for attribute, definition in attributes.sort
      translation += "    "
      translation += "#>"  if definition[1] == :undefined
      translation += "#{attribute}: "+yaml_value(definition[0])
      translation += " #!" if definition[1] == :unused
      translation += "\n"
    end
    translation += "  models:\n"
    for model, definition in models.sort
      next unless definition[2]
      to_translate += hash_count(definition[2])
      translation += "    #{model}:"+yaml_value(definition[2], 2).gsub(/\n/, (definition[1] == :unused ? " #!\n" : "\n"))+"\n"
    end

    File.open(locale_dir.join("models.yml"), "wb") do |file|
      file.write(translation)
    end
    total = to_translate
    log.write "  - #{'models.yml:'.ljust(16)} #{(100*(total-untranslated)/total).round.to_s.rjust(3)}% (#{total-untranslated}/#{total}) #{warnings.to_sentence}\n"
    atotal += to_translate
    acount += total-untranslated


    # Rights
    rights = YAML.load_file(User.rights_file)
    translation  = locale.to_s+":\n"
    translation += "  rights:\n"
    untranslated = 0
    for right in rights.keys.sort
      trans = ::I18n.pretranslate("rights.#{right}")
      untranslated += 1 if trans.match(/^\(\(\(.*\)\)\)$/)
      translation += "    #{right}: "+trans+"\n"
    end
    File.open(locale_dir.join("rights.yml"), "wb") do |file|
      file.write translation
    end
    total = rights.keys.size
    log.write "  - #{'rights.yml:'.ljust(16)} #{(100*(total-untranslated)/total).round.to_s.rjust(3)}% (#{total-untranslated}/#{total})\n"
    atotal += total
    acount += total-untranslated

    count = sort_yaml_file :support, log
    atotal += count
    acount += count


#     log.write "  - help: # Missing files\n"
#     for controller, actions in useful_actions
#       for action in actions
#         if File.exists?("#{Ekylibre::Application.root.to_s}/app/views/#{controller}/#{action}.html.haml") or (File.exists?("#{Ekylibre::Application.root.to_s}/app/views/#{controller}/_#{action.gsub(/_[^_]*$/,'')}_form.html.haml") and action.split("_")[-1].match(/create|update/))
#           unless File.exist?("#{Ekylibre::Application.root.to_s}/config/locales/#{locale}/help/#{controller}-#{action}.txt") or File.exist?("#{Ekylibre::Application.root.to_s}/config/locales/#{locale}/help/#{controller}-#{action.to_s.split(/\_/)[0..-2].join('_').pluralize}.txt") or File.exist?("#{Ekylibre::Application.root.to_s}/config/locales/#{locale}/help/#{controller}-#{action.to_s.pluralize}.txt")
#             log.write "    - ./config/locales/#{locale}/help/#{controller}-#{action}.txt\n" 
#           end
#         end
#       end
#     end

# #     # wkl = [:zho, :cmn, :spa, :eng, :arb, :ara, :hin, :ben, :por, :rus, :jpn, :deu, :jav, :lah, :wuu, :tel, :vie, :mar, :fra, :kor, :tam, :pnb, :ita, :urd, :yue, :arz, :tur, :nan, :guj, :cjy, :pol, :msa, :bho, :awa, :ukr, :hsn, :mal, :kan, :mai, :sun, :mya, :ori, :fas, :mwr, :hak, :pan, :hau, :fil, :pes, :tgl, :ron, :ind, :arq, :nld, :snd, :ary, :gan, :tha, :pus, :uzb, :raj, :yor, :aze, :aec, :uzn, :ibo, :amh, :hne, :orm, :apd, :asm, :hbs, :kur, :ceb, :sin, :acm, :rkt, :tts, :zha, :mlg, :apc, :som, :nep, :skr, :mad, :khm, :bar, :ell, :mag, :ctg, :bgc, :dcc, :azb, :hun, :ful, :cat, :sna, :mup, :syl, :mnp, :zlm, :zul, :que, :ars, :pbu, :ces, :bjj, :aeb, :kmr, :bul, :lmo, :cdo, :dhd, :gaz, :uig, :nya, :bel, :aka, :swe, :kaz, :pst, :bfy, :xho, :hat, :kok, :prs, :ayn, :plt, :azj, :kin, :kik, :acq, :vah, :srp, :nap, :bal, :ilo, :tuk, :hmn, :tat, :gsw, :hye, :ayp, :lua, :ajp, :sat, :vec, :vls, :acw, :kon, :lmn, :sot, :nod, :tir, :sqi, :hil, :mon, :dan, :rwr, :kas, :min, :hrv, :suk, :heb, :mos, :wtm, :kng, :fin, :slk, :afr, :run, :grn, :vmf, :gug, :scn, :bik, :hoj, :nor, :czh, :sou, :hae, :tgk, :tsn, :man, :luo, :kat, :ayl, :aln, :ktu, :lug, :nso, :rmt, :umb, :kau, :wol, :kam, :knn, :mui, :wry, :myi, :doi, :gax, :ckb, :tso, :fuc, :quh, :afb, :gom, :bem, :bjn, :bug, :ace, :bcc, :mvf, :shn, :mzn, :ban, :glk, :knc, :lao, :glg, :tzm, :jam, :lit, :mey, :pms, :czo, :kab, :ewe, :vmw, :kmb, :sdh, :shi, :hrx, :als, :swv, :gdx]
# #     wkl = [:ace, :acm, :acq, :acw, :aeb, :aec, :afb, :afr, :ajp, :aka, :aln, :als, :amh, :apc, :apd, :ara, :arb, :arq, :ars, :ary, :arz, :asm, :awa, :ayl, :ayn, :ayp, :azb, :aze, :azj, :bal, :ban, :bar, :bcc, :bel, :bem, :ben, :bfy, :bgc, :bho, :bik, :bjj, :bjn, :bug, :bul, :cat, :cdo, :ceb, :ces, :cjy, :ckb, :cmn, :ctg, :czh, :czo, :dan, :dcc, :deu, :dhd, :doi, :ell, :eng, :ewe, :fas, :fil, :fin, :fra, :fuc, :ful, :gan, :gax, :gaz, :gdx, :glg, :glk, :gom, :grn, :gsw, :gug, :guj, :hae, :hak, :hat, :hau, :hbs, :heb, :hil, :hin, :hmn, :hne, :hoj, :hrv, :hrx, :hsn, :hun, :hye, :ibo, :ilo, :ind, :ita, :jam, :jav, :jpn, :kab, :kam, :kan, :kas, :kat, :kau, :kaz, :khm, :kik, :kin, :kmb, :kmr, :knc, :kng, :knn, :kok, :kon, :kor, :ktu, :kur, :lah, :lao, :lit, :lmn, :lmo, :lua, :lug, :luo, :mad, :mag, :mai, :mal, :man, :mar, :mey, :min, :mlg, :mnp, :mon, :mos, :msa, :mui, :mup, :mvf, :mwr, :mya, :myi, :mzn, :nan, :nap, :nep, :nld, :nod, :nor, :nso, :nya, :ori, :orm, :pan, :pbu, :pes, :plt, :pms, :pnb, :pol, :por, :prs, :pst, :pus, :que, :quh, :raj, :rkt, :rmt, :ron, :run, :rus, :rwr, :sat, :scn, :sdh, :shi, :shn, :sin, :skr, :slk, :sna, :snd, :som, :sot, :sou, :spa, :sqi, :srp, :suk, :sun, :swe, :swv, :syl, :tam, :tat, :tel, :tgk, :tgl, :tha, :tir, :tsn, :tso, :tts, :tuk, :tur, :tzm, :uig, :ukr, :umb, :urd, :uzb, :uzn, :vah, :vec, :vie, :vls, :vmf, :vmw, :wol, :wry, :wtm, :wuu, :xho, :yor, :yue, :zha, :zho, :zlm, :zul]
#     # Official languages
#     wkl = [:eng, :arb, :cmn, :spa, :fra, :rus, :sqi, :deu, :hye, :aym, :ben, :cat, :kor, :hrv, :dan, :fin, :ell, :hun, :ita, :jpn, :swa, :msa, :mon, :nld, :urd, :fas, :por, :que, :ron, :smo, :srp, :sot, :slk, :slv, :swe, :tam, :tur, :afr, :amh, :aze, :bis, :bel, :mya, :bul, :nya, :sin, :pov, :hat, :crs, :div, :dzo, :est, :fij, :fil, :kat, :gil, :grn, :heb, :urd, :hin, :hmo, :iba, :ind, :gle, :isl, :kaz, :khm, :kir, :run, :lao, :nzs, :lat, :lav, :lit, :ltz, :mkd, :mlg, :mlt, :mri, :rar, :mah, :srp, :nau, :nep, :nor, :uzb, :pus, :pau, :pol, :sag, :swb, :sna, :nde, :som, :tgk, :tzm, :ces, :tet, :tir, :tha, :tpi, :ton, :tuk, :tvl, :ukr, :vie]
#     for reference_path in Dir.glob(Ekylibre::Application.root.join("config", "locales", "*", "languages.yml")).sort
#       lh = yaml_to_hash(reference_path)||{}
#       # puts lh.to_a[0][1][:languages].inspect
#       next if lh.to_a[0][1][:languages].nil?
#       lh.to_a[0][1][:languages].delete_if{|k,v| not wkl.include? k.to_s.to_sym}
#       translation = hash_to_yaml(lh)
#       File.open(reference_path.to_s, "wb") do |file|
#         file.write(translation.strip)
#       end
#     end



#     # ldir = Ekylibre::Application.root.join("config", "locales", locale.to_s)
#     ldir = Ekylibre::Application.root.join("lcx", locale.to_s)
#     FileUtils.makedirs(ldir)
#     for reference_path in Dir.glob(Ekylibre::Application.root.join("config", "locales", ::I18n.default_locale.to_s, "*.yml")).sort
#       file_name = reference_path.split(/[\/\\]+/)[-1]
#       target_path = ldir.join(file_name)
#       translation = hash_to_yaml(yaml_to_hash(reference_path))
#       File.open(target_path, "wb") do |file|
#         file.write(translation.strip)
#       end
#     end

    
    # puts " - Locale: #{::I18n.locale_label} (Reference)"
    total, count = atotal, acount
    log.write "  - Total:           #{(100*count/total).round.to_s.rjust(3)}% (#{count}/#{total})\n"
    puts " - Locale: #{(100*count/total).round.to_s.rjust(3)}% of #{::I18n.locale_label} translated (Reference)"




    for locale in ::I18n.available_locales.delete_if{|l| l==::I18n.default_locale or l.to_s.size!=3}.sort{|a,b| a.to_s<=>b.to_s}
      ::I18n.locale = locale
      locale_dir = Ekylibre::Application.root.join("config", "locales", locale.to_s)
      FileUtils.makedirs(locale_dir) unless File.exist?(locale_dir)
      FileUtils.makedirs(locale_dir.join("help")) unless File.exist?(locale_dir.join("help"))
      log.write "Locale #{::I18n.locale_label}:\n"
      total, count = 0, 0
      for reference_path in Dir.glob(Ekylibre::Application.root.join("config", "locales", ::I18n.default_locale.to_s, "*.yml")).sort
        file_name = reference_path.split(/[\/\\]+/)[-1]
        next if file_name.match(/accounting/)
        target_path = Ekylibre::Application.root.join("config", "locales", locale.to_s, file_name)
        unless File.exist?(target_path)
          File.open(target_path, "wb") do |file|
            file.write("#{locale}:\n")
          end
        end
        target = yaml_to_hash(target_path)
        reference = yaml_to_hash(reference_path)
        translation, scount, stotal = hash_diff(target[locale], reference[::I18n.default_locale], 1)
        count += scount
        total += stotal
        log.write "  - #{(file_name+':').ljust(16)} #{(100*(stotal-scount)/stotal).round.to_s.rjust(3)}% (#{stotal-scount}/#{stotal})\n"
        File.open(target_path, "wb") do |file|
          file.write("#{locale}:\n")
          file.write(translation)
        end
      end
      log.write "  - Total:           #{(100*(total-count)/total).round.to_s.rjust(3)}% (#{total-count}/#{total})\n"
      # Missing help files
      # log.write "  - help: # Missing files\n"
      for controller, actions in useful_actions
        for action in actions
          if File.exists?("#{Ekylibre::Application.root.to_s}/app/views/#{controller}/#{action}.html.haml") or (File.exists?("#{Ekylibre::Application.root.to_s}/app/views/#{controller}/_#{action.gsub(/_[^_]*$/,'')}_form.html.haml") and action.split("_")[-1].match(/create|update/))
            help = "#{Ekylibre::Application.root.to_s}/config/locales/#{locale}/help/#{controller}-#{action}.txt"
            # log.write "    - #{help.gsub(Ekylibre::Application.root.to_s,'.')}\n" unless File.exists?(help)
          end
        end
      end
      puts " - Locale: #{(100*(total-count)/total).round.to_s.rjust(3)}% of #{::I18n.locale_label} translated from reference"
    end

    log.close
  end



  desc "Update fixes for SQL Server in lib/fix_sqlserver.rb"
  task :fix_sqlserver => :environment do
    
    Dir.glob(Ekylibre::Application.root.join("app", "models", "*.rb")).each { |file| require file }

    models = ActiveRecord::Base.subclasses.select{|x| not x.name.match('::')}.sort{|a,b| a.name <=> b.name}
    code = ""
    fixes = 0
    for model in models
      cols = []
      for column in model.columns.sort{|a,b| a.name<=>b.name}
        cols << column.name if column.type == :date
      end
      fixes += cols.size
      code += "  #{model.name}.coerce_sqlserver_date "+cols.sort.collect{|x| ":#{x}"}.join(", ")+"\n" unless cols.blank?
    end
    puts " - SQL Server fixes: #{fixes} columns"

    File.open(Ekylibre::Application.root.join("lib", "fix_sqlserver.rb"), "wb") do |f|
      f.write("# Autogenerated from Ekylibre (`rake clean:fix_sqlserver` or `rake clean`)\n")
      f.write("if ActiveRecord::Base.connection.adapter_name.lower == 'sqlserver'\n")
      f.write("  Time::DATE_FORMATS[:db] = \"%Y-%m-%dT%H:%M:%S\"\n")
      f.write(code)
      f.write("end\n")
    end
  end

  desc "Update SCM version in VERSION"
  task :version => :environment do
    xml = `svn info --xml "#{Rails.root.to_s}"`
    doc = ActiveSupport::XmlMini.parse(xml)
    rev = doc['info']['entry']['commit']['revision'].to_i+1
    puts " - Current revision: #{rev}"
    code = ""
    File.open(Rails.root.join("VERSION"), "rb") do |f|
      code = f.read
    end
    code.gsub!(/,\d*\s*$/, ",#{rev}")
    File.open(Rails.root.join("VERSION"), "wb") do |f|
      f.write(code)
    end
  end


  
end


desc "Clean all files as possible"
task :clean=>[:environment, "clean:rights", "clean:models", "clean:views", "clean:locales", "clean:version", "clean:fix_sqlserver"]

