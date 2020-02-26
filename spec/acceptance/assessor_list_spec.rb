# frozen_string_literal: true

describe 'Acceptance::AssessorList' do
  include RSpecAssessorServiceMixin

  let(:valid_assessor_request_body) do
    {
      firstName: 'Someone',
      middleNames: 'Muddle',
      lastName: 'Person',
      dateOfBirth: '1991-02-25',
      searchResultsComparisonPostcode: '',
      qualifications: { domesticEnergyPerformanceCertificates: 'ACTIVE' },
      contact_details: {
        email: 'someone@energy.gov', telephone_number: '01234 567'
      }
    }
  end

  def fetch_assessors(scheme_id)
    get "/api/schemes/#{scheme_id}/assessors"
  end

  def add_assessor(scheme_id, assessor_id, body)
    put("/api/schemes/#{scheme_id}/assessors/#{assessor_id}", body.to_json)
  end

  def add_scheme(name = 'test scheme')
    JSON.parse(post('/api/schemes', { name: name }.to_json).body)['schemeId']
  end

  def authenticate_with_list_scope(&block)
    authenticate_and(nil, %w[scheme:assessor:list]) { block.call }
  end

  context "when a scheme doesn't exist" do
    it 'returns status 404 for a get' do
      expect(authenticate_with_list_scope { fetch_assessors(20) }.status).to eq(
        404
      )
    end

    it 'returns the error response for a get' do
      expect(authenticate_with_list_scope { fetch_assessors(20) }.body).to eq(
        {
          errors: [
            { "code": 'NOT_FOUND', title: 'The requested scheme was not found' }
          ]
        }.to_json
      )
    end
  end

  context 'when a scheme has no assessors' do
    it 'returns status 200 for a get' do
      scheme_id = authenticate_and { add_scheme }

      expect(
        authenticate_with_list_scope { fetch_assessors(scheme_id) }.status
      ).to eq(200)
    end

    it 'returns an empty list' do
      scheme_id = authenticate_and { add_scheme }
      expected = { 'assessors' => [] }
      response =
        authenticate_with_list_scope { fetch_assessors(scheme_id) }.body
      actual = JSON.parse(response)['data']

      expect(actual).to eq expected
    end

    it 'returns JSON for a get' do
      scheme_id = authenticate_and { add_scheme }
      response = authenticate_with_list_scope { fetch_assessors(scheme_id) }

      expect(response.headers['Content-type']).to eq('application/json')
    end
  end

  context 'when a scheme has one assessor' do
    it 'returns an array of assessors' do
      scheme_id = authenticate_and { add_scheme }
      authenticate_and do
        add_assessor(scheme_id, 'SCHEME4233', valid_assessor_request_body)
      end
      response =
        authenticate_with_list_scope { fetch_assessors(scheme_id) }.body

      actual = JSON.parse(response)['data']
      expected = {
        'assessors' => [
          {
            'registeredBy' => {
              'schemeId' => scheme_id, 'name' => 'test scheme'
            },
            'schemeAssessorId' => 'SCHEME4233',
            'firstName' => valid_assessor_request_body[:firstName],
            'middleNames' => valid_assessor_request_body[:middleNames],
            'lastName' => valid_assessor_request_body[:lastName],
            'dateOfBirth' => valid_assessor_request_body[:dateOfBirth],
            'contactDetails' => {
              'telephoneNumber' => '01234 567', 'email' => 'someone@energy.gov'
            },
            'searchResultsComparisonPostcode' => '',
            'qualifications' => {
              'domesticEnergyPerformanceCertificates' => 'ACTIVE'
            }
          }
        ]
      }

      expect(actual).to eq expected
    end
  end

  context 'when a client is not authenticated' do
    it 'returns a 401 unauthorised' do
      scheme_id = authenticate_and { add_scheme }

      expect(fetch_assessors(scheme_id).status).to eq(401)
    end
  end

  context 'when a client does not have the right role' do
    it 'returns a 403 forbidden' do
      scheme_id = authenticate_and { add_scheme }

      expect(authenticate_and { fetch_assessors(scheme_id) }.status).to eq(403)
    end
  end
end
