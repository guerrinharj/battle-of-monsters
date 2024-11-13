require 'csv'

class MonstersController < ApplicationController
  def new
    @monster = Monster.new
  end

  def show
    begin
      @monster = Monster.find(params[:id])
      render json: { data: @monster }, status: :ok
    rescue ActiveRecord::RecordNotFound => e
      render json: { message: 'The monster does not exists.' }, status: :not_found
    end
  end

  def create
    @monster = Monster.new(monster_params)

    if @monster.save
      render json: { data: @monster }, status: :created
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @monster = Monster.find(params[:id])
  end

  def update
    begin
      @monster = Monster.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      return render json: { message: 'The monster does not exists.' }, status: :not_found
    end

    if @monster.update(monster_params)
      render json: { data: @monster }, status: :ok
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @monster = Monster.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      return render json: { message: 'The monster does not exists.' }, status: :not_found
    end
    
    if @monster.destroy
      redirect_to root_path, status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def import
    file = params[:file]

    if file
      ext = File.extname(file.original_filename)
      unless ['.csv'].include?(ext)
        return render json: { message: 'File should be csv.' }, status: :bad_request
      end

      if (handle = file.tempfile)
        rowData = []
        while !handle.eof?
          rowData << CSV.parse_line(handle.gets)
        end

        csv_data = rowData[1..]

        begin
          CsvImportService.new.import_monster(rowData, csv_data)
          render json: { data: 'Records were imported successfully.' }, status: :ok
        rescue ActiveRecord::StatementInvalid
          render json: { message: 'Wrong data mapping.' }, status: :bad_request
        rescue StandardError
          render json: { message: 'Wrong data mapping.' }, status: :bad_request
        end
      end
    else
      render json: { message: 'Wrong data mapping.' }, status: :bad_request
    end
  end

  private
    def monster_params
      params.require(:monster)
        .permit(:name, :imageUrl, :attack, :defense, :hp, :speed)
    end

    
end
