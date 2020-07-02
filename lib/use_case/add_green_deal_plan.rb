module UseCase
  class AddGreenDealPlan
    class NotFoundException < StandardError; end
    class AssessmentGoneException < StandardError; end
    class InvalidTypeException < StandardError; end

    def initialize
      @assessments_gateway = Gateway::AssessmentsGateway.new
    end

    def execute(assessment_id)
      assessments =
        @assessments_gateway.search_by_assessment_id assessment_id, false

      assessment = assessments.first

      raise NotFoundException unless assessment

      if %w[CANCELLED NOT_FOR_ISSUE].include? assessment.to_hash[:status]
        raise AssessmentGoneException
      end

      unless %w[RdSAP].include? assessment.to_hash[:type_of_assessment]
        raise InvalidTypeException
      end
    end
  end
end