class UsersController < ApplicationController
  before_filter :signed_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  before_filter :correct_user,   only: [:edit, :update]
  before_filter :admin_user,     only: :destroy

  def show
  	@user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    if signed_in?
      redirect_to root_url
    else
  	 @user = User.new
    end
  end

  def find
    @user = User.new
  end

  def index
    @users = User.paginate(page: params[:page])
  end

  def create
    if signed_in?
      redirect_to root_url
    else
  	 @user = User.new(params[:user])
    	if @user.save
        sign_in @user
        flash[:success] = "Welcome to the Sample App!"
        redirect_to @user
    	else
    		render 'new'
    	end
    end
  end

  def destroy
    to_be_destroyed = User.find(params[:id])
    if current_user != to_be_destroyed
      to_be_destroyed.destroy
      flash[:success] = "User destroyed"
      redirect_to users_url
    else
      flash[:error] = "You cannot destroy yourself"
      redirect_to users_url
    end
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  def edit
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated"
      sign_in @user
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end
