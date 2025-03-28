# frozen_string_literal: true

require 'contracts'

RSpec.describe Contracts::CHO do
  subject(:contract) { Contracts::CHO.new.call(cho) }

  describe 'required language-specific fields' do
    %i[
      cho_title
    ].each do |field_name|
      describe field_name do
        context 'when missing' do
          let(:cho) { {} }

          it 'states the field is missing' do
            expect(contract.errors[field_name]).to include('is missing')
          end
        end

        context 'when not a hash' do
          let(:cho) { { field_name => 'foo' } }

          it 'states the field is not a hash' do
            expect(contract.errors[field_name]).to include('must be a hash')
          end
        end

        context 'when an empty hash' do
          let(:cho) { { field_name => {} } }

          it 'states the field contained no values' do
            expect(contract.errors[field_name]).to include('no values provided')
          end
        end

        context 'when hash contains unexpected keys' do
          let(:cho) { { field_name => { unknown_language_key: ['value1'] } } }

          it 'states the field had unexpected keys' do
            expect(contract.errors[field_name]).to include(
              "unexpected language code(s) found in #{field_name}: unknown_language_key"
            )
          end
        end

        context 'when hash contains unexpected values' do
          let(:cho) { { field_name => { 'none' => ['none', ['The Real Value']] } } }

          it 'states the field had unexpected keys' do
            expect(contract.errors[field_name]).to include(
              "unexpected non-string value(s) found in #{field_name}: [[\"The Real Value\"]]"
            )
          end
        end

        context 'when hash looks as expected' do
          let(:cho) do
            {
              field_name => {
                'none' => ['value1'],
                'en' => %w[value2 value3],
                'tr-Latn' => ['value4']
              }
            }
          end

          it 'has no errors' do
            expect(contract.errors[field_name]).to be_nil
          end
        end
      end
    end
  end

  describe 'optional language-specific fields' do
    %i[
      cho_description
    ].each do |field_name|
      describe field_name do
        context 'when missing' do
          let(:cho) { {} }

          it 'has no errors' do
            expect(contract.errors[field_name]).to be_nil
          end
        end

        context 'when not a hash' do
          let(:cho) { { field_name => 'foo' } }

          it 'states the field is not a hash' do
            expect(contract.errors[field_name]).to include('must be a hash')
          end
        end

        context 'when an empty hash' do
          let(:cho) { { field_name => {} } }

          it 'has no errors' do
            expect(contract.errors[field_name]).to be_nil
          end
        end

        context 'when hash contains unexpected keys' do
          let(:cho) { { field_name => { unknown_language_key: ['value1'] } } }

          it 'states the field had unexpected keys' do
            expect(contract.errors[field_name]).to include(
              "unexpected language code(s) found in #{field_name}: unknown_language_key"
            )
          end
        end

        context 'when hash contains unexpected values' do
          let(:cho) { { field_name => { 'none' => ['none', ['The Real Value']] } } }

          it 'states the field had unexpected keys' do
            expect(contract.errors[field_name]).to include(
              "unexpected non-string value(s) found in #{field_name}: [[\"The Real Value\"]]"
            )
          end
        end

        context 'when hash contains the value NOT FOUND' do
          let(:cho) { { field_name => { 'none' => ['NOT FOUND'] } } }

          it 'states the field included NOT FOUND' do
            expect(contract.errors[field_name]).to include(
              'unknown language found (NOT FOUND)'
            )
          end
        end

        context 'when hash looks as expected' do
          let(:cho) do
            {
              field_name => {
                'none' => ['value1'],
                'en' => %w[value2 value3],
                'tr-Latn' => ['value4']
              }
            }
          end

          it 'has no errors' do
            expect(contract.errors[field_name]).to be_nil
          end
        end
      end
    end
  end

  describe 'required language normalization fields' do
    %i[
      agg_data_provider
      agg_data_provider_country
      agg_provider
      agg_provider_country
    ].each do |field_name|
      describe field_name do
        context 'when hash looks as expected' do
          let(:cho) do
            {
              field_name => {
                'en' => ['value'],
                'ar-Arab' => ['قيمة']
              }
            }
          end

          it 'has no errors' do
            expect(contract.errors[field_name]).to be_nil
          end
        end

        context 'when Arabic key is missing' do
          let(:cho) do
            {
              field_name => {
                'en' => ['value']
              }
            }
          end

          it 'raises an error' do
            expect(contract.errors[field_name]).to include(
              "Arabic language code is missing from #{field_name}"
            )
          end
        end

        context 'when English key is missing' do
          let(:cho) do
            {
              field_name => {
                'ar-Arab' => ['قيمة']
              }
            }
          end

          it 'raises an error' do
            expect(contract.errors[field_name]).to include(
              "English language code is missing from #{field_name}"
            )
          end
        end
      end
    end
  end

  describe 'cho_edm_type_control_vocab' do
    %i[
      cho_edm_type
    ].each do |field_name|
      describe field_name do
        context 'when value in field is in the controlled vocabulary' do
          let(:cho) do
            {
              field_name => {
                'en' => ['Text']
              }
            }
          end

          it 'has no errors' do
            expect(contract.errors[field_name]).to be_nil
          end
        end

        context 'when value in field is not in the controlled vocabulary' do
          let(:cho) do
            {
              field_name => {
                'en' => ['book']
              }
            }
          end

          it 'raises an error' do
            expect(contract.errors[field_name]).to include(
              'unexpected edm_type value(s) found : book'
            )
          end
        end
      end
    end
  end

  describe 'cho_has_type_control_vocab' do
    %i[
      cho_has_type
    ].each do |field_name|
      describe field_name do
        context 'when value in field is in the controlled vocabulary' do
          let(:cho) do
            {
              field_name => {
                'en' => ['Books']
              }
            }
          end

          it 'has no errors' do
            expect(contract.errors[field_name]).to be_nil
          end
        end

        context 'when value in field is not in the controlled vocabulary' do
          let(:cho) do
            {
              field_name => {
                'en' => ['text']
              }
            }
          end

          it 'raises an error' do
            expect(contract.errors[field_name]).to include(
              'unexpected has_type value(s) found : text'
            )
          end
        end
      end
    end
  end

  describe 'singular web resource fields' do
    %i[
      agg_is_shown_at
      agg_is_shown_by
    ].each do |field_name|
      describe field_name do
        context 'when not provided' do
          let(:cho) { {} }

          it 'has no errors' do
            expect(contract.errors[field_name]).to be_nil
          end
        end

        context 'when provided value abides by EDMWebResource contract' do
          let(:cho) do
            {
              field_name => {
                wr_id: 'http://example.com'
              }
            }
          end

          it 'has no errors' do
            expect(contract.errors[field_name]).to be_nil
          end
        end

        context 'when provided value breaks EDMWebResource contract' do
          let(:cho) do
            {
              field_name => {}
            }
          end

          it 'has errors' do
            expect(contract.errors[field_name]).to include('is missing')
          end
        end
      end
    end
  end

  describe 'agg_has_view (a plural web resource field)' do
    context 'when not provided' do
      let(:cho) { {} }

      it 'has no errors' do
        expect(contract.errors[:agg_has_view]).to be_nil
      end
    end

    context 'when value is not array' do
      let(:cho) do
        {
          agg_has_view: {
            wr_id: 'web_resource_id'
          }
        }
      end

      it 'has errors' do
        expect(contract.errors[:agg_has_view]).to include('must be an array')
      end
    end

    context 'when provided value abides by EDMWebResource contract' do
      let(:cho) do
        {
          agg_has_view: [
            {
              wr_id: 'http://example.com'
            }
          ]
        }
      end

      it 'has no errors' do
        expect(contract.errors[:agg_has_view]).to be_nil
      end
    end

    context 'when provided value breaks EDMWebResource contract' do
      let(:cho) do
        {
          agg_has_view: [{}]
        }
      end

      it 'has errors' do
        expect(contract.errors[:agg_has_view].values.flatten).to include('is missing')
      end
    end
  end
end
