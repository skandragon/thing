# == Schema Information
#
# Table name: changelogs
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  action      :string(255)
#  target_id   :integer
#  target_type :string(255)
#  changelog   :text
#  notified    :boolean          default(FALSE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  original    :text
#  committed   :text
#  year        :integer
#

require 'rails_helper'

describe Changelog do
  describe '#useless?' do
    it 'returns true for {}' do
      cl = Changelog.new(changelog: {})
      expect(cl).to be_useless
    end

    it 'returns true for nil' do
      cl = Changelog.new(changelog: nil)
      expect(cl).to be_useless
    end
  end

  describe '#build_destroy' do
    it 'should render current values for a simple object' do
      i = build(:instructable)
      cl = Changelog.build_destroy(i, nil)
      expect(cl.original).to have_key('name')
      expect(cl.original['name']).to eql i.name
    end

    it 'renders related objects' do
      i = create(:scheduled_instructable)
      i.reload
      cl = Changelog.build_destroy(i, nil)
      expect(cl.original).to have_key('instances')
      expect(cl.original['instances']).to be_a_kind_of(Array)
      expect(cl.original['instances'].size).to eql i.repeat_count
    end
  end

  describe '#sanitize_changes' do
    it 'removes unneeded deltas' do
      data = {
        :instance => {
          1 => { foo: [1, 1] }
        }
      }
      ret = Changelog.send(:sanitize_changes, data)
      expect(ret).to eql({})
    end

    it 'removes if only whitespace changes' do
      data = {
        :instance => {
          1 => { foo: ['this', "\nthis"] }
        }
      }
      ret = Changelog.send(:sanitize_changes, data)
      expect(ret).to eql({})
    end

    it "removes if one is nil and another ''" do
      data = {
        :instance => {
          1 => { foo: [nil, ''] }
        }
      }
      ret = Changelog.send(:sanitize_changes, data)
      expect(ret).to eql({})
    end

    it 'removes if both nil' do
      data = {
        :instance => {
          1 => { foo: [nil, nil] }
        }
      }
      ret = Changelog.send(:sanitize_changes, data)
      expect(ret).to eql({})
    end

    it 'keeps nested deltas' do
      data = {
        :instance => {
          1 => { foo: [1, 2] }
        }
      }
      ret = Changelog.send(:sanitize_changes, data)
      expect(ret).to have_key('instance')
      expect(ret['instance']).to have_key('1')
      expect(ret['instance']['1']).to have_key('foo')
      expect(ret['instance']['1']['foo']).to eql [1, 2]
    end

    it 'keeps deltas' do
      data = { foo: [1, 2] }
      ret = Changelog.send(:sanitize_changes, data)
      expect(ret).to have_key('foo')
      expect(ret['foo']).to eql [1, 2]
    end
  end

  describe '#decompose' do
    it 'handles empty data' do
      expect(Changelog.decompose({})).to eql({})
    end

    it 'handles simple data' do
      data = { foo: [1, 2], bar: [3, 4] }
      ret = Changelog.decompose(data)
      expect(ret.keys.size).to eql 2
      expect(ret).to have_key('foo')
      expect(ret['foo']).to eql [1, 2]
      expect(ret).to have_key('bar')
      expect(ret['bar']).to eql [3, 4]
    end

    it 'handles nested deltas' do
      data = {
        :instance => {
          1 => { foo: [1, 2] }
        }
      }
      ret = Changelog.decompose(data)
      expect(ret).to have_key('instance-1-foo')
      expect(ret['instance-1-foo']).to eql [1, 2]
    end

  end
end
