class Tag < ActiveRecord::Base
  has_many :book_tags, dependent: :destroy
  has_many :books, through: :book_tags
  acts_as_nested_set

  def self.generate_hierarchy_hash(current_nodes=nil)
    current_nodes ||= [Tag.root]

    current_nodes.map do |cn|
      {
        :tag_id => cn.id,
        :text => cn.name,
        :state => {:checked => true},
        :nodes => cn.children.any? ? Tag.generate_hierarchy_hash(cn.children) : nil 
      }      
    end
  end
end