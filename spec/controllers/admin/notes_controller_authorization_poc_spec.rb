# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::NotesController, type: :controller do
  let!(:blog) { create(:blog) }
  let(:owner) { create(:user, :as_publisher) }
  let(:other_publisher) { create(:user, :as_publisher) }
  let!(:note) { create(:note, user: owner, blog: blog, body: "owner's original note") }

  before { sign_in other_publisher }

  describe "positive proof of cross-publisher note authorization bypass" do
    it "allows another publisher to load the owner's edit page" do
      get :edit, params: { id: note.id }

      expect(response).not_to be_redirect
      expect(assigns(:note)).to eq(note)
    end

    it "allows another publisher to modify the owner's note" do
      post :update, params: { id: note.id, note: { body: "changed by another publisher" } }

      expect(note.reload.body).to eq("changed by another publisher")
    end

    it "allows another publisher to delete the owner's note" do
      expect do
        delete :destroy, params: { id: note.id }
      end.to change(Note, :count).by(-1)
    end
  end
end
