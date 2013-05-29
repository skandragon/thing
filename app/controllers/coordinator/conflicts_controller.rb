class Coordinator::ConflictsController < ApplicationController
  def index
    @type_to_field_mapping = {
      instructor: :titled_sca_name,
      topic: :topic,
      location: :formatted_location,
    }
    @conflicts = ConflictCheck.conflicts
  end
end
