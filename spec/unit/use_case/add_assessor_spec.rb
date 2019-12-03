# frozen_string_literal: true

describe UseCase::AddAssessor do
  VALID_ASSESSOR =
    {
      first_name: 'John',
      last_name: 'Smith',
      middle_names: 'Brain',
      date_of_birth: '1991-02-25'
    }

  class SchemesGatewayStub
    def initialize(result)
      @result = result
    end

    def all(*)
      @result
    end
  end

  context 'when adding an assessor' do
    let(:add_assessor_with_stub_data) do
      schemes_gateway = SchemesGatewayStub.new([{ scheme_id: 25, name: 'Best scheme' }])
      described_class.new(schemes_gateway)
    end

    it 'returns an error if the scheme doesnt exist' do
      schemes_gateway = SchemesGatewayStub.new([])
      add_assessor = described_class.new(schemes_gateway)
      expect { add_assessor.execute('6', 'SCHE24352', VALID_ASSESSOR) }.to raise_exception(UseCase::AddAssessor::SchemeNotFoundException)
    end

    it 'returns no errors if the scheme does exist' do
      expect { add_assessor_with_stub_data.execute('25', 'SCHE904572', VALID_ASSESSOR) }.to_not raise_exception
    end

    it 'returns the scheme that the assessor belongs to' do
      expect(add_assessor_with_stub_data.execute('25', 'SCHE234950', VALID_ASSESSOR)[:registeredBy]).to eq(schemeId: '25', name: 'Best scheme')
    end

    it 'returns the scheme assessor ID' do
      expect(add_assessor_with_stub_data.execute('25', 'SCHE234950', VALID_ASSESSOR)[:schemeAssessorId]).to eq('SCHE234950')
    end

    it 'returns the assessors first name' do
      expect(add_assessor_with_stub_data.execute('25', 'SCHE234950', VALID_ASSESSOR)[:firstName]).to eq('John')
    end

    it 'returns the assessors last name' do
      expect(add_assessor_with_stub_data.execute('25', 'SCHE234950', VALID_ASSESSOR)[:lastName]).to eq('Smith')
    end

    it 'returns the assessors middle names' do
      expect(add_assessor_with_stub_data.execute('25', 'SCHE234950', VALID_ASSESSOR)[:middleNames]).to eq('Brain')
    end

    it 'returns the assessors date of birth' do
      expect(add_assessor_with_stub_data.execute('25', 'SCHE234950', VALID_ASSESSOR)[:dateOfBirth]).to eq('1991-02-25')
    end
  end

  context 'when adding with invalid data' do
    let(:add_assessor_with_stub_data) do
      schemes_gateway = SchemesGatewayStub.new([{ scheme_id: 25, name: 'Best scheme' }])
      described_class.new(schemes_gateway)
    end

    it 'rejects American style dates of birth' do
      assessor = VALID_ASSESSOR.dup
      assessor[:date_of_birth] = "12/20/1990"

      expect { add_assessor_with_stub_data.execute('25', 'SCHE93452', assessor) }.to raise_exception(UseCase::AddAssessor::InvalidAssessorDetailsException)
    end

    it 'rejects UK style dates of birth with slashes' do
      assessor = VALID_ASSESSOR.dup
      assessor[:date_of_birth] = "10/12/1990"

      expect { add_assessor_with_stub_data.execute('25', 'SCHE93452', assessor) }.to raise_exception(UseCase::AddAssessor::InvalidAssessorDetailsException)
    end

    it 'rejects dates that arent dates at all' do
      assessor = VALID_ASSESSOR.dup
      assessor[:date_of_birth] = "55555555555"

      expect { add_assessor_with_stub_data.execute('25', 'SCHE93452', assessor) }.to raise_exception(UseCase::AddAssessor::InvalidAssessorDetailsException)
    end

    it 'rejects dates that are YYYY-DD-MM' do
      assessor = VALID_ASSESSOR.dup
      assessor[:date_of_birth] = "1990-30-07"

      expect { add_assessor_with_stub_data.execute('25', 'SCHE93452', assessor) }.to raise_exception(UseCase::AddAssessor::InvalidAssessorDetailsException)
    end
  end
end
