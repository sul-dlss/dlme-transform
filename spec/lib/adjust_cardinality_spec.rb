# frozen_string_literal: true

require 'adjust_cardinality'

RSpec.describe AdjustCardinality do
  subject(:adjusted) { AdjustCardinality.call attributes }

  describe 'flatten_web_resources' do
    context 'when flattened web resource id is an array' do
      let(:attributes) do
        { 'agg_has_view' => [
          {
            'wr_id' => ['http://hgl.harvard.edu/HGL/hgl.jsp?VCollName=G8201_E424']
          }
        ] }
      end

      it 'flattens the web resource id' do
        expect(adjusted['agg_has_view']).to eq([
                                                 {
                                                   'wr_id' => 'http://hgl.harvard.edu/HGL/hgl.jsp?VCollName=G8201_E424'
                                                 }
                                               ])
      end
    end
    context 'when flattened web resource id is not an array' do
      let(:attributes) do
        { 'agg_has_view' =>
          {
            'wr_id' => ['http://hgl.harvard.edu/HGL/hgl.jsp?VCollName=G8201_E424']
          } }
      end

      it 'still flattens the web resource id' do
        expect(adjusted['agg_has_view']).to eq(
          'wr_id' => 'http://hgl.harvard.edu/HGL/hgl.jsp?VCollName=G8201_E424'
        )
      end
    end
  end
end
