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
    @profile = current_user.build_instructor_profile(params[:instructor_profile])
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
    if @profile.update_attributes(params[:instructor_profile])
      redirect_to root_path, notice: "Instructor profile updated."
    else
      render action: :edit
    end
  end
end
