class Post < ApplicationRecord
  belongs_to :discussion, counter_cache: true, touch: true
  belongs_to :user, default: -> { Current.user }
  has_rich_text :body
  has_noticed_notifications
  validates :body, presence: true
  delegate :username, to: :user

  after_create_commit -> { broadcast_append_to discussion, partial: 'discussions/posts/post', locals: { post: self } }
  after_update_commit -> { broadcast_replace_to discussion, partial: 'discussions/posts/post', locals: { post: self } }
  after_destroy_commit -> { broadcast_remove_to discussion }
  after_create :send_notification

  def send_notification
    #notifications for all users except current_user
    #post_subscribers = discussion.subscribed_users - [user]
    #notifications for all users
    post_subscribers = discussion.subscribed_users
    NewPostNotification.with(post: self).deliver_later(post_subscribers)
  end
end