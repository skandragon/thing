class InstructorProfilesController < ApplicationController
  def new
    if current_user.instructor?
      redirect_to edit_user_instructor_profile_path(current_user)
      return
    end
    @profile = current_user.build_instructor_profile
    @profile.add_missing_contacts
    render action: :edit
  end

  def create
    @profile = current_user.build_instructor_profile(permitted_params)
    if @profile.save
      redirect_to root_path, notice: "Instructor profile created."
    else
      render action: :edit
    end
  end

  def edit
    unless current_user.instructor?
      redirect_to new_user_instructor_profile_path(current_user)
      return
    end
    @profile = current_user.instructor_profile
    @profile.add_missing_contacts
  end

  def update
    @profile = current_user.instructor_profile
    if @profile.update_attributes(permitted_params)
      redirect_to root_path, notice: "Instructor profile updated."
    else
      render action: :edit
    end
  end

  private

  def permitted_params
    params.require(:instructor_profile).permit(
      :mundane_name, :phone_number, :sca_name, :sca_title, :phone_number_onsite,
      :kingdom, :no_contact, :available_days,
      { :instructor_profile_contacts => [ :address, :protocol ] }
    )
  end
end
