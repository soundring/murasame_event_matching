module ImageValidatable
  extend ActiveSupport::Concern

  ALLOWED_IMAGE_TYPES = ["image/jpeg", "image/png", "image/gif", "image/webp"].freeze
  MAX_IMAGE_SIZE = 5.megabytes

  included do
    validate :validate_image
  end

  private

  def validate_image
    return unless image.attached?

    unless ALLOWED_IMAGE_TYPES.include?(image.content_type)
      errors.add(:image, "はJPEG, PNG, GIF, WebP形式のみアップロード可能です。")
    end

    if image.byte_size > MAX_IMAGE_SIZE
      errors.add(:image, "のファイルサイズは#{MAX_IMAGE_SIZE / 1.megabyte}MB以内にしてください。")
    end
  end
end
