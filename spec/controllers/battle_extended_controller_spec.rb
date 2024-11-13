# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BattlesExtendedController, type: :controller do
  before(:each) do
    @monster1 = FactoryBot.create(:monster,
                                  name: 'My monster Test 1',
                                  attack: 40,
                                  defense: 20,
                                  hp: 50,
                                  speed: 80,
                                  imageUrl: 'https://example.com/image.jpg')

    @monster2 = FactoryBot.create(:monster,
                                  name: 'My monster Test 2',
                                  attack: 60,
                                  defense: 10,
                                  hp: 40,
                                  speed: 90,
                                  imageUrl: 'https://example.com/image2.jpg')

    # Please include additional monsters here for testing purposes.
  end

  def create_battles
    FactoryBot.create_list(:battle, 2)
  end

  # TODO: Update the below test as necessary
  it 'should create battle with bad request if one parameter is null' do
    post :create, params: { monsterA: @monster1.id, monsterB: nil }
    expect(response).to have_http_status(:bad_request)
  end

  # TODO: Update the below test as necessary
  it 'should create battle with bad request if monster does not exists' do
    post :create, params: { monsterA: @monster1.id, monsterB: 500 }
    expect(response).to have_http_status(:bad_request)
  end

  # TODO: Update the below test as necessary
  it 'should create battle correctly with monsterA winning' do
    @monster1.update(hp: 1000)

    post :create, params: { monsterA_id: @monster1.id, monsterB_id: @monster2.id }

    response_data = JSON.parse(response.body)
    expect(response_data['battle']['winner_id']).to eq(@monster1.id)
  end

  # TODO: Update the below test as necessary
  it 'should create battle correctly with monsterB winning with equal defense and monsterB higher speed' do
    @monster1.update(defense: 70)
    @monster2.update(defense: 70, speed: 200)

    post :create, params: { monsterA_id: @monster1.id, monsterB_id: @monster2.id }

    response_data = JSON.parse(response.body)
    expect(response_data['battle']['winner_id']).to eq(@monster2.id)
  end

  # TODO: Update the below test as necessary
  it 'should delete a battle correctly' do
    post :create, params: { monsterA_id: @monster1.id, monsterB_id: @monster2.id }
    response_data = JSON.parse(response.body)

    battle_id = response_data['battle']['id']

    delete :destroy, params: { id: battle_id }
    expect(response).to have_http_status(:ok)
  end

  # TODO: Update the below test as necessary
  it 'should fail delete when battle does not exist' do

    delete :destroy, params: { id: 9000 }
    expect(response).to have_http_status(:bad_request)
    
  end
end
