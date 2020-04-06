module Backend
  class VarietiesController < Backend::BaseController
    def selection
      @varieties = Nomen::Variety.selection(params[:specie])
    end
  end
end
