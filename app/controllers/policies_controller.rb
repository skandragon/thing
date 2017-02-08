class PoliciesController < ApplicationController
  def show
    policy = params[:id]
    not_found unless supported_policy(policy)
    @accept_needed = (current_user and !Policy::has_current_policy?(current_user))
    render policy
  end

  def accept
    policy = params[:id]
    not_found unless supported_policy(policy)
    if Policy::has_current_policy?(current_user)
      render text: "You have already accepted this policy version."
    else
      Policy.create!(version: Policy::CURRENT_VERSION, area: policy, user_id: current_user.id, accepted_on: Time.now)
      redirect_to root_path, notice: "Your acceptance of the Pennsic University policies has been recorded."
    end
  end

  private

  def supported_policy(policy)
    ['university'].include?policy
  end
end
