tenants = Ekylibre::Tenant.list
count = tenants.count
tenants.each_with_index do |tenant, index|
  puts "Processing tenant #{index + 1} / #{count} (#{tenant})"
  begin
    Ekylibre::Tenant.switch! tenant
  rescue
    next
  end
  ActiveRecord::Base.transaction do
    phytos = Variants::Articles::PlantMedicineArticle.where.not(france_maaid: nil)

    phytos.each do |phyto|
      matching_products = RegisteredPhytosanitaryProduct.where(france_maaid: phyto.france_maaid).where.not(state: 'HERITE')
      next unless matching_products.any?
      phyto.update!(reference_name: matching_products.first.reference_name, imported_from: 'Lexicon')
    end
  end
end
