# encoding: utf-8

class ArticlesController < ApplicationController

  before_action :authenticate_supplier_admin!

  # GET /supplier/:id/articles
  # GET /supplier/:id/articles.xml
  def index
    if params[:filter]
      @filter = params[:filter]
      @articles = @supplier.articles
      @articles = @articles.where('name LIKE ?', "%#{@filter}%") unless @filter.nil?
      @articles = @articles.page(params[:page])
    elsif params[:order]
      case params[:order]
      when 'updated_on'
        @articles = @supplier.articles.all.page(params[:page]).order(updated_on: :desc)
        @updated_on = true
      end
    else
      @articles = @supplier.articles.page(params[:page])
    end

    respond_to do |format|
      format.html # index.haml
      format.xml  { render :xml => @articles.to_xml }
    end
  end

  # GET /supplier/1/articles/1
  # GET /supplier/1/articles/1.xml
  def show
    @article = @supplier.articles.find(params[:id])

    respond_to do |format|
      format.html # show.haml
      format.xml  { render :xml => @article.to_xml }
    end
  end

  # GET /supplier/1/articles/new
  def new
    @article = @supplier.articles.build
  end

  # GET /supplier/1/articles/1/edit
  def edit
    @article = @supplier.articles.find(params[:id])
  end

  # POST /supplier/1/articles
  # POST /supplier/1/articles.xml
  def create
    @article = Article.new(article_params)
    respond_to do |format|
      if @article.save
        flash[:notice] = 'Article was successfully created.'
        format.html { redirect_to supplier_article_url(@article.supplier, @article) }
        format.xml  { head :created, :location => supplier_article_url(@article.supplier, @article) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @article.errors.to_xml }
      end
    end
  end

  # PUT /supplier/1/articles/1
  # PUT /supplier/1/articles/1.xml
  def update
    @article = @supplier.articles.find(params[:id])
    respond_to do |format|
      if @article.update(article_params)
        flash[:notice] = 'Article was successfully updated.'
        format.html { redirect_to supplier_article_url(@article.supplier, @article) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @article.errors.to_xml }
      end
    end
  end

  # DELETE /supplier/1/articles/1
  # DELETE /supplier/1/articles/1.xml
  def destroy
    @article = @supplier.articles.find(params[:id])
    @article.destroy

    respond_to do |format|
      format.html { redirect_to supplier_articles_url(@supplier) }
      format.xml  { head :ok }
    end
  end

  # Renders the upload form
  def upload
  end

  # parse the file to load articles
  # checks if the article should be updated, create or destroyed
  def parse
    if params[:articles].blank?
      flash[:error] = "Please select a file to import"
      redirect_to upload_supplier_articles_url(@supplier)
      return
    end
    if params[:type].blank?
      flash[:error] = "Please select a file-format"
      redirect_to upload_supplier_articles_url(@supplier)
      return
    end

    file = params[:articles]["file"].tempfile
    filename = params[:articles]["file"].original_filename
    type = params[:type].presence
    encoding = params[:encoding].presence

    begin
      Article.transaction do
        Article.where(supplier_id: @supplier.id).delete_all unless params[:delete_existing].blank?

        @outlisted_counter, @new_counter, @updated_counter, @invalid_articles =
            @supplier.update_articles_from_file(file, type: type, encoding: encoding, filename: filename)

        if @invalid_articles.empty?
          flash[:notice] = "Hochladen erfolgreich: #{@new_counter} neue, #{@updated_counter} aktualisiert und #{@outlisted_counter} ausgelistet."
          redirect_to supplier_articles_url(@supplier)
        else
          flash[:error] = "#{@invalid_articles.size} Artikel konnte(n) nicht gespeichert werden"
          render :template => 'articles/parse_errors'
        end
      end
    rescue => error
      flash[:error] = "Fehler beim hochladen der Artikel: #{error.message}"
      redirect_to upload_supplier_articles_url(@supplier)
    end
  end

  # deletes all articles of a supplier
  def destroy_all
    Article.where(supplier_id: @supplier.id).delete_all
    flash[:notice] = "Alle Artikel wurden gelöscht"
    redirect_to supplier_articles_url(@supplier), status: :see_other
  end

  private

  def article_params
    params
      .require(:article)
      .permit(
        :name,
        :number,
        :note,
        :manufacturer,
        :origin,
        :unit,
        :price,
        :tax,
        :deposit,
        :unit_quantity,
        :category,
        :scale_quantity,
        :scale_price,
        :supplier_id
      )
  end
end
