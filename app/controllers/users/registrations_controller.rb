# https://gist.github.com/kazpsp/3350730

class Users::RegistrationsController < Devise::RegistrationsController
  def resource_params
    params.require(:user).permit(:current_password, :mundane_name, :email, :password, :password_confirmation)
  end
  private :resource_params
end
