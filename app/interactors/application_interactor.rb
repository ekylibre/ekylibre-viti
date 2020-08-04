require 'interactor'

class ApplicationInteractor
  def self.inherited(base)
    base.instance_exec do
      include Interactor
    end
  end
end