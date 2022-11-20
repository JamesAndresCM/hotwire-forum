module HasSlug
  extend ActiveSupport::Concern
  def to_param = "#{id}-#{name.downcase.to_s[0...100]}".parameterize
end
