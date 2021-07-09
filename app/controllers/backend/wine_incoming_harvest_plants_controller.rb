module Backend
  class WineIncomingHarvestPlantsController < Backend::BaseController
    def net_harvest_area
      plant = Plant.find_by_id(params[:plant_id])
      area = Measure.new((params[:percentage].to_f / 100) * plant.net_surface_area.to_f, :hectare).round_l

      respond_to do |format|
        format.json { render json: { net_harvest_area: "(#{area})" } }
      end
    end
  end
end
