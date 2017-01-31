class PoliciesController < ApplicationController
  def show
    policy = params[:id]
    if ['university'].include?policy
      render policy
    else
      not_found
    end
  end
end
