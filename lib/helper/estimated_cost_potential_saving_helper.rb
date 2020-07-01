# frozen_string_literal: true

module Helper
  class EstimatedCostPotentialSavingHelper
    def estimated_cost(
      lighting_cost_current, heating_cost_current, hot_water_cost_current
    )
      estimated_cost = [
        lighting_cost_current,
        heating_cost_current,
        hot_water_cost_current,
      ].compact.sum
      estimated_cost
    end

    def potential_saving(
      lighting_cost_potential,
      heating_cost_potential,
      hot_water_cost_potential,
      estimated_cost = 0
    )
      potential_saving_sum = [
        lighting_cost_potential,
        heating_cost_potential,
        hot_water_cost_potential,
      ].compact.sum
      total_potential_saving = estimated_cost - potential_saving_sum
      total_potential_saving.round(2)
    end
  end
end
