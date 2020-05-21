describe UseCase::SearchAddressesByStreetAndTown do
  context "addresses without a lodged assessment" do
    let(:use_case) { described_class.new AddressSearchGatewayFake.new }

    describe "by postcode" do
      it "does not return any results" do
        results = use_case.execute street: "Fake Street", town: "Ghost"

        expect(results).to eq []
      end
    end
  end

  context "addresses with a lodged assessment" do
    let(:gateway) do
      gateway = AddressSearchGatewayFake.new

      gateway.add(
        {
          building_reference_number: "RRN-0000-0000-0000-0000-0000",
          line1: "127 Home Road",
          line2: nil,
          line3: nil,
          town: "Placeville",
          postcode: "PL4 V11",
        },
      )

      gateway.add(
        {
          building_reference_number: "RRN-0000-0000-0000-0000-0001",
          line1: "128 Home Road",
          line2: nil,
          line3: nil,
          town: "Placeville",
          postcode: "PL4 V12",
        },
      )

      gateway.add(
        {
          building_reference_number: "RRN-0000-0000-0000-0000-0002",
          line1: "The Name",
          line2: "129 Home Road",
          line3: nil,
          town: "Placeville",
          postcode: "PL4 V13",
        },
      )

      gateway
    end
    let(:use_case) { described_class.new gateway }

    describe "by street and town" do
      it "returns the expected address" do
        results = use_case.execute street: "Home Road", town: "Placeville"

        expect(results.length).to eq 3
        expect(
          results[0].building_reference_number,
        ).to eq "RRN-0000-0000-0000-0000-0000"
        expect(results[0].line1).to eq "127 Home Road"
        expect(results[0].line2).to be_nil
        expect(results[0].line3).to be_nil
        expect(results[0].town).to eq "Placeville"
        expect(results[0].postcode).to eq "PL4 V11"
      end

      context "when street is on address line 2" do
        it "returns the expected address" do
          results = use_case.execute street: "Home Road", town: "Placeville"

          expect(results.length).to eq 3
          expect(
            results[2].building_reference_number,
          ).to eq "RRN-0000-0000-0000-0000-0002"
          expect(results[2].line1).to eq "The Name"
          expect(results[2].line2).to eq "129 Home Road"
          expect(results[2].line3).to be_nil
          expect(results[2].town).to eq "Placeville"
          expect(results[2].postcode).to eq "PL4 V13"
        end
      end
    end
  end
end
