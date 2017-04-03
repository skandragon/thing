require 'rails_helper'

describe InstructorsController, type: :controller do
  before :each do
    @instructor1 = create(:instructor, kingdom: 'ansteorra')
    create(:instructable, user_id: @instructor1.id)

    @instructor2 = create(:instructor, kingdom: 'calontir')
    create(:instructable, user_id: @instructor2.id)

    @classless_instructor1 = create(:instructor, kingdom: 'trimaris')

    visit instructors_path
  end

  it 'should show names' do
    expect(page).to have_content @instructor1.titled_sca_name
    expect(page).to have_content @instructor2.titled_sca_name
    expect(page).to_not have_content @classless_instructor1.titled_sca_name
  end

  it 'should show names by kingdom' do
    click_on 'By kingdom'
    expect(page).to have_content @instructor1.kingdom.titleize
    expect(page).to have_content @instructor1.titled_sca_name
    expect(page).to have_content @instructor2.kingdom.titleize
    expect(page).to have_content @instructor2.titled_sca_name
    expect(page).to_not have_content @classless_instructor1.kingdom.titleize
    expect(page).to_not have_content @classless_instructor1.titled_sca_name
  end
end
