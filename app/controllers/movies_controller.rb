class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :edit, :update, :destroy]

  # GET /movies
  def index
    @all_ratings = Movie.all_ratings
    
    if !session.key?(:ratings) || !session.key?(:sort_by)
      @all_ratings_hash = Hash[@all_ratings.collect {|key| [key, '1']}]
      session[:ratings] = @all_ratings_hash if !session.key?(:ratings)
      session[:sort_by] = '' if !session.key?(:sort_by)
      redirect_to movies_path(:ratings => @all_ratings_hash, :sort_by => '') and return
    end
    
    if (!params.has_key?(:ratings) && session.key?(:ratings)) ||
      (!params.has_key?(:sort_by) && session.key?(:sort_by))
      redirect_to movies_path(:ratings => Hash[session[:ratings].collect {|key| [key, '1']}], :sort_by => session[:sort_by]) and return
    end
    
    @ratings_to_show = params[:ratings].keys
    @ratings_to_show_hash = Hash[@ratings_to_show.collect {|key| [key, '1']}]
    session[:ratings] = @ratings_to_show
    
    @movies = Movie.with_ratings(@ratings_to_show)
    
    @movies = @movies.order(params[:sort_by]) if params[:sort_by] != ''
    session[:sort_by] = params[:sort_by]
    @title_header = (params[:sort_by]=='title') ? 'hilite bg-warning' : ''
    @release_date_header = (params[:sort_by]=='release_date') ? 'hilite bg-warning' : ''
  end

  # GET /movies/1
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
    @movie = Movie.find params[:id]
  end

  # POST /movies
  def create
    @movie = Movie.new(movie_params)

    if @movie.save
      redirect_to @movie, notice: 'Movie was successfully created.'
    else
      render :new
    end
  end
  

  # PATCH/PUT /movies/1
  def update
    if @movie.update(movie_params)
      redirect_to @movie, notice: 'Movie was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /movies/1
  def destroy
    @movie.destroy
    redirect_to movies_url, notice: 'Movie was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
end
