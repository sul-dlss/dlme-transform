# frozen_string_literal: true

require 'contracts'

RSpec.describe Contracts::CHO do
  subject(:contract) { Contracts::CHO.new.call(cho) }

  describe 'cho_title' do
    context 'when missing' do
      let(:cho) { {} }

      it 'states the field is missing' do
        expect(contract.errors[:cho_title]).to include('is missing')
      end
    end

    context 'when not a hash' do
      let(:cho) { { cho_title: 'foo' } }

      it 'states the field is not a hash' do
        expect(contract.errors[:cho_title]).to include('must be a hash')
      end
    end

    context 'when an empty hash' do
      let(:cho) { { cho_title: {} } }

      it 'states the field contained no values' do
        expect(contract.errors[:cho_title]).to include('no values provided')
      end
    end

    context 'when hash contains unexpected keys' do
      let(:cho) { { cho_title: { unknown_language_key: ['title1'] } } }

      it 'states the field had unexpected keys' do
        expect(contract.errors[:cho_title]).to include(
          'unexpected language code(s) found in cho_title: unknown_language_key'
        )
      end
    end

    context 'when hash looks as expected' do
      let(:cho) do
        {
          cho_title: {
            'none' => ['title1'],
            'en' => %w[title2 title3],
            'tr-Latn' => ['title4']
          }
        }
      end

      it 'has no errors' do
        expect(contract.errors[:cho_title]).to be_nil
      end
    end
  end

  describe 'agg_is_shown_at' do
    context 'when not provided' do
      let(:cho) { {} }

      it 'has no errors' do
        expect(contract.errors[:agg_is_shown_at]).to be_nil
      end
    end

    context 'when provided value abides by EDMWebResource contract' do
      let(:cho) do
        {
          agg_is_shown_at: {
            wr_id: 'web_resource_id'
          }
        }
      end

      it 'has no errors' do
        expect(contract.errors[:agg_is_shown_at]).to be_nil
      end
    end

    context 'when provided value breaks EDMWebResource contract' do
      let(:cho) do
        {
          agg_is_shown_at: {}
        }
      end

      it 'has errors' do
        expect(contract.errors[:agg_is_shown_at]).to include('is missing')
      end
    end
  end

  describe 'agg_is_shown_by' do
    context 'when not provided' do
      let(:cho) { {} }

      it 'has no errors' do
        expect(contract.errors[:agg_is_shown_by]).to be_nil
      end
    end

    context 'when provided value abides by EDMWebResource contract' do
      let(:cho) do
        {
          agg_is_shown_by: {
            wr_id: 'web_resource_id'
          }
        }
      end

      it 'has no errors' do
        expect(contract.errors[:agg_is_shown_by]).to be_nil
      end
    end

    context 'when provided value breaks EDMWebResource contract' do
      let(:cho) do
        {
          agg_is_shown_by: {}
        }
      end

      it 'has errors' do
        expect(contract.errors[:agg_is_shown_by]).to include('is missing')
      end
    end
  end

  describe 'agg_preview' do
    context 'when not provided' do
      let(:cho) { {} }

      it 'has no errors' do
        expect(contract.errors[:agg_preview]).to be_nil
      end
    end

    context 'when provided value abides by EDMWebResource contract' do
      let(:cho) do
        {
          agg_preview: {
            wr_id: 'web_resource_id'
          }
        }
      end

      it 'has no errors' do
        expect(contract.errors[:agg_preview]).to be_nil
      end
    end

    context 'when provided value breaks EDMWebResource contract' do
      let(:cho) do
        {
          agg_preview: {}
        }
      end

      it 'has errors' do
        expect(contract.errors[:agg_preview]).to include('is missing')
      end
    end
  end

  describe 'agg_has_view' do
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
              wr_id: 'web_resource_id'
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
        expect(contract.errors[:agg_has_view]).to include('is missing')
      end
    end
  end
end
