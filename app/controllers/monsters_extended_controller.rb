# frozen_string_literal: true

class MonstersExtendedController < MonstersController
  def index
    # TODO: Retrieves all monsters

    @monsters = Monster.all

    render json: { monsters: @monsters }
  end
end
