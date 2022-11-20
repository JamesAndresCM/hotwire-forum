class Notification < ApplicationRecord
  include Noticed::Model
  belongs_to :recipient, polymorphic: true

  after_create_commit do
    broadcast_replace_to "broadcast_to_user_#{recipient_id}",
    target: 'notifications_count',
    partial: 'notifications/count',
    locals: { count: recipient.unviewed_notifications_count }
  end
end
