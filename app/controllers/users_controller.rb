class UsersController < ApplicationController

  before_action :admin_required!

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:notice] = "Konto wurde erfolgreich erstellt."
      redirect_to @user
    else
      render :new
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:notice] = 'Konto wurde erfolgreich aktualisiert.'
      redirect_to @user
    else
      render :edit
    end
  end

  def show
    @user = User.find_by_id(params[:id])
  end

  def index
    @users = User.all
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.xml  { head :ok }
    end
  end

  private
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :admin)
  end
end
