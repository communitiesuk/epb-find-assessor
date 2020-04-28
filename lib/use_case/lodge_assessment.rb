# frozen_string_literal: true

module UseCase
  class LodgeAssessment
    class InactiveAssessorException < StandardError; end
    class AssessmentIdMismatchException < StandardError; end
    class DuplicateAssessmentIdException < StandardError; end
    class AssessmentRuleException < StandardError; end

    def initialize(domestic_energy_assessments_gateway, assessors_gateway)
      @domestic_energy_assessments_gateway = domestic_energy_assessments_gateway
      @assessors_gateway = assessors_gateway
    end

    def execute(lodgement, assessment_id)
      data = lodgement.fetch_data

      unless assessment_id == lodgement.assessment_id
        raise AssessmentIdMismatchException
      end

      if @domestic_energy_assessments_gateway.fetch assessment_id
        raise DuplicateAssessmentIdException
      end

      scheme_assessor_id = lodgement.scheme_assessor_id

      address_summary =
        [
          data[:address_line_one],
          data[:address_line_two],
          data[:address_line_three],
          data[:town],
          data[:postcode]
        ].compact
          .join(', ')

      expiry_date = Date.parse(data[:inspection_date]).next_year(10).to_s

      assessor = @assessors_gateway.fetch scheme_assessor_id

      if lodgement.type == 'RdSAP' &&
           assessor.domestic_rd_sap_qualification == 'INACTIVE'
        raise InactiveAssessorException
      end

      if lodgement.type == 'SAP' &&
           assessor.domestic_sap_qualification == 'INACTIVE'
        raise InactiveAssessorException
      end

      assessment =
        Domain::DomesticEnergyAssessment.new(
          data[:inspection_date],
          data[:registration_date],
          data[:dwelling_type],
          lodgement.type,
          data[:total_floor_area],
          data[:assessment_id],
          assessor,
          address_summary,
          data[:current_energy_rating].to_i,
          data[:potential_energy_rating].to_i,
          data[:postcode],
          expiry_date,
          data[:address_line_one],
          data[:address_line_two] || '',
          data[:address_line_three] || '',
          '',
          data[:town],
          data[:space_heating] || data[:new_space_heating],
          data[:water_heating] || data[:new_water_heating],
          data[:impact_of_loft_insulation],
          data[:impact_of_cavity_insulation],
          data[:impact_of_solid_wall_insulation],
          lodgement.suggested_improvements
        )

      validator = Helper::RdsapValidator::ValidateAll.new
      errors = validator.validate assessment

      raise AssessmentRuleException, errors.to_json unless errors.empty?

      @domestic_energy_assessments_gateway.insert_or_update assessment

      assessment
    end
  end
end
