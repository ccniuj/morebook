class Profile < ActiveRecord::Base
  self.primary_key = 'user_id'

  belongs_to :user

  has_attached_file :selfie, styles: { medium: "300x300#", thumb: "100x100#" }, 
    default_url: '/images/:styles/selfie_missing.png'
  validates_attachment_content_type :selfie, content_type: /\Aimage\/.*\Z/

end