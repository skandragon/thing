class Coordinator::ConflictsController < ApplicationController
  def index
    @conflicts = ConflictCheck.conflicts
  end
end
