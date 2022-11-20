class MoveCategory < ApplicationService
  attr_reader :discussion

  def initialize(discussion)
    @discussion = discussion
    super()
  end

  def call
    replace_header
    replace_new_post_form if discussion.saved_change_to_closed?
    move_category if discussion.saved_change_to_category_id?
  end

  private

  def replace_header
    discussion.broadcast_replace(partial: 'discussions/header', locals: { discussion: discussion })
  end

  def set_category(category)
    Category.find(category)
  end

  def move_category
    old_category_id, new_category_id = discussion.saved_change_to_category_id
    old_category = set_category(old_category_id)
    new_category = set_category(new_category_id)

    discussion.broadcast_remove_to(old_category)
    discussion.broadcast_prepend_to(new_category)

    old_category.reload.broadcast_replace_to('categories')
    new_category.reload.broadcast_replace_to('categories')
  end

  def replace_new_post_form
    discussion.broadcast_action_to(
      discussion,
      action: :replace,
      target: 'new_post_form',
      partial: 'discussions/posts/form',
      locals: { post: discussion.posts.new }
    )
  end
end
