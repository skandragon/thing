# https://gist.github.com/kazpsp/3350730

class Users::PasswordsController < Devise::PasswordsController
  def resource_params
    params.require(:user).permit(:email, :mundane_name, :password, :password_confirmation, :reset_password_token)
  end
  private :resource_params
end
