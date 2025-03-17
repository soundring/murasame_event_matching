require 'rails_helper'

RSpec.describe ImageValidatable, type: :model do
  before(:all) do
    ActiveRecord::Schema.define do
      create_table :dummy_models, force: true do |t|
        t.string :name
        t.timestamps
      end
    end

    class DummyModel < ApplicationRecord
      include ImageValidatable
      has_one_attached :image
    end
  end

  after(:all) do
    Object.send(:remove_const, :DummyModel)
  end

  let(:model) { DummyModel.new }

  let(:valid_image_jpeg) do
    file = fixture_file_upload(
      Rails.root.join('spec/fixtures/test_image.jpg'),
      'image/jpeg'
    )
    file
  end

  let(:invalid_file) do
    file = fixture_file_upload(
      Rails.root.join('spec/fixtures/test.txt'),
      'text/plain'
    )
    file
  end

  describe "#validate_image" do
    context "画像が未添付の場合" do
      it "バリデーションエラーにならない" do
        expect(model).to be_valid
      end
    end

    context "許可された画像が添付されている場合" do
      it "バリデーションに通ること" do
        model.image.attach(io: valid_image_jpeg, filename: "valid_image.jpg", content_type: "image/jpeg")
        expect(model).to be_valid
      end
    end

    context "許可されていないコンテンツタイプの場合" do
      it "バリデーションエラーになること" do
        model.image.attach(io: invalid_file, filename: "dummy.txt", content_type: "text/plain")
        model.valid?
        expect(model.errors[:image]).to include("はJPEG, PNG, GIF, WebP形式のみアップロード可能です。")
      end
    end

    context "画像のサイズが制限を超えている場合" do
      it "バリデーションエラーになること" do
        model.image.attach(io: valid_image_jpeg, filename: "valid_image.jpg", content_type: "image/jpeg")
        # サイズチェックのため、byte_sizeをスタブで6MBに設定
        allow_any_instance_of(ActiveStorage::Blob).to receive(:byte_size).and_return(6.megabytes)
        model.valid?
        expect(model.errors[:image]).to include("のファイルサイズは5MB以内にしてください。")
      end
    end
  end
end
