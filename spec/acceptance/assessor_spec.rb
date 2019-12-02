describe AssessorService do
  describe 'The Assessor API' do
    VALID_ASSESSOR_REQUEST_BODY = {
        firstName: 'Some',
        middleNames: 'middle',
        lastName: 'Person',
        dateOfBirth: '1991-02-25'
    }

    def fetch_assessor(scheme_id, assessor_id)
      get "/api/schemes/#{scheme_id}/assessors/#{assessor_id}"
    end

    def add_assessor(scheme_id, assessor_id, body)
      put("/api/schemes/#{scheme_id}/assessors/#{assessor_id}", body.to_json)
    end

    def add_scheme(scheme_name)
      post("/api/schemes", { name: scheme_name }.to_json)
    end

    context 'When a scheme doesnt exist' do
      it 'returns status 404 for a get' do
        expect(fetch_assessor(20, 'SCHEME4233').status).to eq(404)
      end

      it 'returns status 404 for a PUT' do
        expect(add_assessor(20, 'SCHEME4532', VALID_ASSESSOR_REQUEST_BODY).status).to eq(404)
      end
    end

    context 'when an assessor doesnt exist' do
      it 'returns status 404' do
        schemeid = JSON.parse(add_scheme('scheme245').body)['schemeId']

        expect(fetch_assessor(schemeid, 'SCHE2354246').status).to eq(404)
      end
    end

    context 'when getting an assessor on the wrong scheme' do
      let(:post_response) { post('/api/schemes', { name: 'scheme245'}.to_json) }

      it 'returns status 404' do
        schemeid = JSON.parse(add_scheme('scheme245').body)['schemeId']
        second_schemeid = JSON.parse(add_scheme('scheme987').body)['schemeId']
        add_assessor(second_schemeid, 'SCHE987654', VALID_ASSESSOR_REQUEST_BODY)

        expect(fetch_assessor(schemeid, 'SCHE987654').status).to eq(404)
      end
    end
  end
end
