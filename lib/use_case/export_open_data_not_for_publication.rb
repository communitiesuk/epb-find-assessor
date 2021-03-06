module UseCase
  class ExportOpenDataNotForPublication
    def initialize(reporting_gateway)
      @reporting_gateway = reporting_gateway || Gateway::ReportingGateway.new
    end

    def execute
      array = []
      assessments = @reporting_gateway.fetch_not_for_publication_assessments
      assessments.each do |assessment|
        assessment["assessment_id"] =
          Helper::RrnHelper.hash_rrn(assessment["assessment_id"])
        array << assessment.symbolize_keys
      end
      array
    end
  end
end
