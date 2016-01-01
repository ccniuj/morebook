class Tag < ActiveRecord::Base
  has_many :book_tags, dependent: :destroy
  has_many :books, through: :book_tags
  acts_as_nested_set

  def self.add_child_tag(parent_tag_id, tag_name)
    parent_tag = self.where(id: parent_tag_id).first
    c = self.create(:name => tag_name)
    c.move_to_child_of(parent_tag)
    c.id
  end
end