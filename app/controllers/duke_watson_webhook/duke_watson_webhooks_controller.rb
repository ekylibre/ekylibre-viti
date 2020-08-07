class DukeWatsonWebhooksController < ApplicationController
skip_before_action :verify_authenticity_token

  def handle_webhook
    begin
      event = params["main_param"]
      class_ = ('Duke::'+event["hook_skill"]).constantize.new
      response = class_.send "handle_"+event["hook_request"], event
    end
    render json: response
  end

end
