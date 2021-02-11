require "nokogiri"

module UseCase
  class ExportOpenDataDomestic
    ASSESSMENT_TYPE = %w[RdSAP SAP].freeze

    def initialize
      @gateway = Gateway::ReportingGateway.new
      @assessment_gateway = Gateway::AssessmentsXmlGateway.new
      @log_gateway = Gateway::OpenDataLogGateway.new
    end

    def execute(task_id = 1, date_from)
      data = []
      assessment_type = "CEPC"
      assessments =
        @gateway.assessments_for_open_data(ASSESSMENT_TYPE, task_id, date_from)

      assessments.each do |assessment|
        xml_data = @assessment_gateway.fetch(assessment["assessment_id"])
        view_model =
          ViewModel::Factory.new.create(
            xml_data[:xml],
            xml_data[:schema_type],
            assessment["assessment_id"],
          )
        view_model_hash = view_model.to_report

        view_model_hash[:lodgement_date] =
          assessment["date_registered"].strftime("%F")
        view_model_hash[:lodgement_datetime] =
          assessment["date_registered"].strftime("%F %H:%M:%S")
        @log_gateway.insert(assessment["assessment_id"], task_id, "Domestic")
        view_model_hash[:rrn] =
          Helper::RrnHelper.hash_rrn(assessment["assessment_id"])

        data << view_model_hash
      end
      data
    end
  end
end
