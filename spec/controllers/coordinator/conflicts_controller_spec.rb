require 'rails_helper'

describe Coordinator::ConflictsController, type: :controller do
  before :each do
    log_in tracks: ['Middle Eastern']
    @user = create(:instructor)
  end

  it 'shows a message for no instances' do
    visit coordinator_conflicts_path
    expect(page).to have_content 'No conflicts found.'
  end

  it 'shows a message for only one instance' do
    @ia = create(:instructable, user_id: @user.id)
    @a = @ia.instances.create!(start_time: get_date(1), location: 'A&S 1')

    visit coordinator_conflicts_path
    expect(page).to have_content 'No conflicts found.'
  end

  it 'shows a message for no conflicts' do
    @ia = create(:instructable, user_id: @user.id)
    @a = @ia.instances.create!(start_time: get_date(1))
    @ib = create(:instructable, user_id: @user.id)
    @b = @ib.instances.create!(start_time: get_date(2))

    visit coordinator_conflicts_path
    expect(page).to have_content 'No conflicts found.'
  end

  it 'shows a table if there is a conflict' do
    @ia = create(:instructable, user_id: @user.id)
    @a = @ia.instances.create!(start_time: get_date(1), location: 'A&S 1')
    @ib = create(:instructable, user_id: @user.id)
    @b = @ib.instances.create!(start_time: get_date(1), location: 'A&S 1')

    visit coordinator_conflicts_path
    expect(page).to have_content @ia.name
    expect(page).to have_content @ib.name
  end
end
