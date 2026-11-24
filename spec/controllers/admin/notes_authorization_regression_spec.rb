# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::NotesController, type: :controller do
  let!(:blog) { create(:blog) }
  let(:owner) { create(:user, :as_publisher) }
  let(:other_publisher) { create(:user, :as_publisher) }
  let!(:note) { create(:note, user: owner, blog: blog, body: "owner's original note") }

  before { sign_in other_publisher }

  describe "publisher access to another publisher's note" do
    it "does not expose the edit form" do
      get :edit, params: { id: note.id }

      expect(response).to redirect_to(controller: "/admin/dashboard", action: "index")
    end

    it "does not allow updating the note" do
      post :update, params: { id: note.id, note: { body: "changed by another publisher" } }

      expect(note.reload.body).to eq("owner's original note")
    end

    it "does not allow deleting the note" do
      expect do
        delete :destroy, params: { id: note.id }
      end.not_to change(Note, :count)
    end
  end
end
