# frozen_string_literal: true

class BattlesExtendedController < BattlesController
  skip_forgery_protection only: [:create, :destroy]

  def create
    # TODO: Implement a Battle Algorithm

    @monster1 = Monster.find_by(id: params[:monsterA_id])
    @monster2 = Monster.find_by(id: params[:monsterB_id])

    if @monster1.nil? || @monster2.nil?
      render json: { error: "Missing monsters" }, status: :bad_request
      return
    end

    first_attacker = define_first_attacker(@monster1, @monster2)
    second_attacker = (@monster1 == first_attacker) ? @monster2 : @monster1

    loop do
      second_attacker.hp -= first_attacker.attack
      break if second_attacker.hp <= 0

      first_attacker.hp -= second_attacker.attack
      break if first_attacker.hp <= 0
    end

    @winner = first_attacker.hp > 0 ? first_attacker : second_attacker 

    @battle = Battle.new(winner_id: @winner.id, monsterA_id: @monster1.id, monsterB_id: @monster2.id)
    @battle.save!

    render json: { battle: @battle }
  end

  def destroy
    # TODO: Destroy a battle
    @battle = Battle.find_by(id: params[:id])
    if @battle
      @battle.destroy
      render json: { success: "Battle deleted!" }, status: :ok
    else
      render json: { success: "Battle doesnt exist!" }, status: :bad_request
    end
  end

  private

  def define_first_attacker(monster1, monster2)
    if monster1.speed > monster2.speed
      monster1
    elsif monster1.speed == monster2.speed
      monster1.attack >= monster2.attack ? monster1 : monster2
    else
      monster2
    end
  end
end
