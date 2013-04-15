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
#


require 'spec_helper'

describe Changelog do
  describe '#sanitize_changes' do
    it "removes unneeded deltas" do
      data = {
        :instance => {
          1 => { foo: [1, 1] }
        }
      }
      ret = Changelog.send(:sanitize_changes, data)
      ret.should == {}
    end

    it "keeps nested deltas" do
      data = {
        :instance => {
          1 => { foo: [1, 2] }
        }
      }
      ret = Changelog.send(:sanitize_changes, data)
      ret.should have_key("instance")
      ret["instance"].should have_key("1")
      ret["instance"]["1"].should have_key("foo")
      ret["instance"]["1"]["foo"].should == [1, 2]
    end

    it "keeps deltas" do
      data = { foo: [1, 2] }
      ret = Changelog.send(:sanitize_changes, data)
      ret.should have_key("foo")
      ret["foo"].should == [1, 2]
    end
  end

  describe '#decompose' do
    it "handles empty data" do
      Changelog.decompose({}).should == {}
    end

    it "handles simple data" do
      data = { foo: [1, 2], bar: [3, 4] }
      ret = Changelog.decompose(data)
      ret.keys.size.should == 2
      ret.should have_key("foo")
      ret["foo"].should == [1, 2]
      ret.should have_key("bar")
      ret["bar"].should == [3, 4]
    end

    it "handles nested deltas" do
      data = {
        :instance => {
          1 => { foo: [1, 2] }
        }
      }
      ret = Changelog.decompose(data)
      ret.should have_key("instance-1-foo")
      ret["instance-1-foo"].should == [1, 2]
    end

  end
end
