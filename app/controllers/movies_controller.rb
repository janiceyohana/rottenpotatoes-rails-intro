class MoviesController < ApplicationController
  before_action :set_movie, only: [:show, :edit, :update, :destroy]

  # GET /movies
  def index
    @all_ratings = Movie.all_ratings
    @ratings_to_show_hash = params[:ratings] || session[:ratings] || @all_ratings.map{ |rating| [rating, "1"] }.to_h
    @movies = Movie.with_ratings(@ratings_to_show_hash.keys)
    @sort_column = params[:sort] || session[:sort]
    
    session[:sort] = @sort_column
    session[:ratings] = @ratings_to_show_hash

    case @sort_column
    when 'title'
      @movies = @movies.order(title: :asc)
    when 'release_date'
      @movies = @movies.order(release_date: :asc)
    end
  end

  # GET /movies/1
  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  # GET /movies/new
  def new
  end

  # GET /movies/1/edit
  def edit
    @movie = Movie.find params[:id]
  end

  # POST /movies
  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] =  "#{@movie.title} was successfully created."
    redirect_to movies_path
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
