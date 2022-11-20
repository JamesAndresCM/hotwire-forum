class Discussion < ApplicationRecord
  include HasSlug
  belongs_to :user, default: -> { Current.user }
  belongs_to :category, counter_cache: true, touch: true
  has_many :posts, dependent: :destroy
  has_many :users, through: :posts
  has_many :discussion_subscriptions, dependent: :destroy
  has_many :optin_subscribers, -> { where(discussion_subscriptions: { subscription_type: :optin }) }, through: :discussion_subscriptions, source: :user
  has_many :optout_subscribers, -> { where(discussion_subscriptions: { subscription_type: :optout }) }, through: :discussion_subscriptions, source: :user
  validates :name, presence: true
  delegate :name, prefix: :category, to: :category, allow_nil: true

  accepts_nested_attributes_for :posts
  scope :pinned_first, -> { order(pinned: :desc, updated_at: :desc) }

  broadcasts_to :category, inserts_by: :prepend
  after_create_commit -> { broadcast_prepend_to 'discussions' }
  after_update_commit -> { broadcast_replace_to 'discussions' }
  after_destroy_commit -> { broadcast_remove_to 'discussions' }

  def subscribed_users
    (users + optin_subscribers).uniq - optout_subscribers
  end

  def subscribed?(user)
    return false if user.nil?

    if subscription = subscription_for(user)
      subscription.subscription_type == 'optin'
    else
      posts.where(user_id: user.id).any?
    end
  end

  def subscription_for(user)
    return nil if user.nil?

    discussion_subscriptions.find_by(user_id: user.id)
  end

  def toggle_subscription(user)
    if subscription = subscription_for(user)
      subscription.toggle!
    elsif posts.where(user_id: user.id).any?
      discussion_subscriptions.create(user: user, subscription_type: :optout)
    else
      discussion_subscriptions.create(user: user, subscription_type: :optin)
    end
  end

  def subscribed_reason(user)
    return "You're not receiving notifications from this thread" if user.nil?

    if subscription = subscription_for(user)
      if subscription.subscription_type == 'optout'
        "You're ignoring this thread"
      elsif subscription.subscription_type == 'optin'
        "You're receiving notifications because you've subscribed to this thead"
      end
    elsif posts.where(user_id: user.id).any?
      "You're receiving notifications because you've posted in this thread"
    else
      "You're not receiving notifications from this thread"
    end
  end
end