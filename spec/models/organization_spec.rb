require 'rails_helper'

describe Organization do

  subject { create(:organization) }

  describe "verified?" do
    it "is false when verified_at? is blank" do
      expect(subject.verified?).to be false
    end
    it "is true when verified_at? exists" do
      subject.verified_at = Time.now
      expect(subject.verified?).to be true
    end
    it "is false when the organization was verified and then rejected" do
      subject.verified_at = Time.now
      subject.rejected_at = Time.now + 1
      expect(subject.verified?).to be false
    end
    it "is true when the organization was rejected and then verified" do
      subject.rejected_at = Time.now
      subject.verified_at = Time.now + 1
      expect(subject.verified?).to be true
    end
  end

  describe "rejected?" do
    it "is false when rejected_at? is blank" do
      expect(subject.rejected?).to be false
    end
    it "is true when rejected_at? exists" do
      subject.rejected_at = Time.now
      expect(subject.rejected?).to be true
    end
    it "is true when the organization was verified and then rejected" do
      subject.verified_at = Time.now
      subject.rejected_at = Time.now + 1
      expect(subject.rejected?).to be true
    end
    it "is false when the organization was rejected and then verified" do
      subject.rejected_at = Time.now
      subject.verified_at = Time.now + 1
      expect(subject.rejected?).to be false
    end
  end

  describe "self.search" do
    before(:each) {@organization = create(:organization, name: "Watershed", user: create(:user, phone_number: "333"))}

    it "returns no results if search term is empty" do
      expect(Organization.search(" ").size).to eq(0)
    end

    it "finds fuzzily by name" do
      expect(Organization.search("Greenpeace").size).to eq 0
      search = Organization.search("Tershe")
      expect(search.size).to eq 1
      expect(search.first).to eq @organization
    end

    scenario "finds by users email" do
      search = Organization.search(@organization.user.email)
      expect(search.size).to eq 1
      expect(search.first).to eq @organization
    end

    scenario "finds by users phone number" do
      search = Organization.search(@organization.user.phone_number)
      expect(search.size).to eq 1
      expect(search.first).to eq @organization
    end
  end
end
