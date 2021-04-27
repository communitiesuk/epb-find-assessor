module UseCase
  class ImportXmlAttributeValues
    attr_accessor :xml_doc, :xml_nodes

    def initialize
      @assessment_attribute_gateway = Gateway::AssessmentAttributesGateway.new
    end

    def execute(xml_doc)
      @xml_doc = xml_doc
      @xml_nodes = xml_doc.descendant_elements

      # pp to_count_hash.sort_by{ |key| key }
      # insert address
      pp childless_nodes =
           to_count_hash.select do |key, value|
             value == 1 && key.include?("address")
           end
    end

  private

    def attribute_nodes
      @xml_nodes.reject do |node|
        node.element_children.nil? || node.element_children.length > 0
      end
    end

    def node_names
      @xml_nodes.map { |node| node.name }
    end

    def to_count_hash
      grouped_nodes = node_names.group_by { |i| i }
      grouped_nodes.map { |key, value| [key, value.length] }.to_h
    end
  end
end

class Nokogiri::XML::Node
  def descendant_elements
    child_nodes = element_children.to_a
    child_nodes.concat(child_nodes.map(&:descendant_elements)).flatten
  end
end
