# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MonstersExtendedController, type: :controller do
  def create_monsters
    FactoryBot.create_list(:monster, 1)
  end

  it 'should get all monsters correctly' do
    create_monsters
    get :index
    response_data = JSON.parse(response.body)

    expect(response_data['monsters'].count).to eq(Monster.count)
  end

  # TODO: Update the below test as necessary
  it 'should import all the CSV objects into the database successfully' do
    monsters = create_monsters

    csv_content = CSV.generate(headers: true) do |csv|
      csv << ['name', 'attack', 'defense', 'hp', 'speed', 'imageUrl']
        monsters.each do |monster|
          csv << [monster.name, monster.attack, monster.defense, monster.hp, monster.speed, monster.imageUrl] 
        end
    end

    file = Tempfile.new(['monsters', '.csv'])
    file.write(csv_content)
    file.rewind

    post :import, params: { file: Rack::Test::UploadedFile.new(file.path) }
    expect(response).to have_http_status(:ok)
  end

  # TODO: Update the below test as necessary
  it 'should fail when importing csv file with inexistent columns' do
    monsters = create_monsters

    csv_content = CSV.generate(headers: true) do |csv|
      csv << ['name', 'attack', 'defense', 'hp', 'speed', 'imageUrl', "inexistent column"]
        monsters.each do |monster|
          csv << ['Monster1'] 
        end
    end

    file = Tempfile.new(['monsters', '.csv'])
    file.write(csv_content)
    file.rewind

    post :import, params: { file: Rack::Test::UploadedFile.new(file.path) }
    expect(response).to have_http_status(:bad_request)
  end

  # TODO: Update the below test as necessary
  it 'should fail when importing csv file with wrong columns' do
    monsters = create_monsters

    csv_content = CSV.generate(headers: true) do |csv|
      csv << ["inexistent column"]
        monsters.each do |monster|
          csv << ['Monster1'] 
        end
    end

    file = Tempfile.new(['monsters', '.csv'])
    file.write(csv_content)
    file.rewind

    post :import, params: { file: Rack::Test::UploadedFile.new(file.path) }
    expect(response).to have_http_status(:bad_request)   
  end

  # TODO: Update the below test as necessary
  it 'should fail when importing file with different extension' do
    monsters = create_monsters

    file = Tempfile.new(['monsters', '.blabla'])
    file.write("blabla")
    file.rewind

    post :import, params: { file: Rack::Test::UploadedFile.new(file.path) }
    expect(response).to have_http_status(:bad_request)   
    
  end

  # TODO: Update the below test as necessary
  it 'should fail when importing none file' do
    post :import

    expect(response).to have_http_status(:bad_request)      
  end
end
