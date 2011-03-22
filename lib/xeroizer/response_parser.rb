module Xeroizer
  class ResponseParser
    
    class << self
    
      # Parse the response retreived during any request.
      def parse_response(raw_response, request = {}, options = {}, &block)
        response = Xeroizer::Response.new
        response.response_xml = raw_response
      
        doc = Nokogiri::XML(raw_response) { | cfg | cfg.noblanks }
      
        # check for responses we don't understand
        raise Xeroizer::UnparseableResponse.new(doc.root.name) unless doc.root.name == 'Response'
      
        doc.root.elements.each do | element |
                    
          # Text element
          if element.children && element.children.size == 1 && element.children.first.text?
            case element.name
              when 'Id'           then response.id = element.text
              when 'Status'       then response.status = element.text
              when 'ProviderName' then response.provider = element.text
              when 'DateTimeUTC'  then response.date_time = Time.parse(element.text)
            end
          
          # Records in response
          elsif element.children && element.children.size > 0
            yield(response, element.children, element.children.first.name)
          end
        end
      
        response.response_items
      end
      
    end
    
  end
end