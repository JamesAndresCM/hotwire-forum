class DiscussionsController < ApplicationController
  before_action :set_discussion, only: %i[edit update destroy show]

  def index
    @pagy, @discussions = pagy(Discussion.includes(:category).pinned_first)
  end

  def new
    @discussion = Discussion.new
    @discussion.posts.new
  end

  def edit; end

  def show
    @new_post = @discussion.posts.new
    @pagy, @posts = pagy(@discussion.posts.includes(:user, :rich_text_body).order(created_at: :asc), items: 5)
  end

  def create
    @discussion = Discussion.new(discussion_params)

    respond_to do |format|
      if @discussion.save
        format.html { redirect_to discussions_path, notice: 'Discussion created' }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @discussion.update(discussion_params)
        MoveCategory.call(@discussion)
        format.html { redirect_to discussions_path, notice: 'Discussion updated' }
      else
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @discussion.destroy!
    redirect_to discussions_path, notice: 'Discussion removed'
  end

  private

  def discussion_params = params.require(:discussion).permit(:name, :category_id, :closed, :pinned, posts_attributes: :body)
  def set_discussion = @discussion = Discussion.find(params[:id])
end
