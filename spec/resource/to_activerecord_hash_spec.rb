require 'json/api'

describe JSON::API::Resource, '.to_activerecord_hash' do
  before(:all) do
    @payload = {
      'data' => {
        'type' => 'articles',
        'id' => '1',
        'attributes' => {
          'title' => 'JSON API paints my bikeshed!',
          'rating' => '5 stars'
        },
        'relationships' => {
          'author' => {
            'data' => { 'type' => 'people', 'id' => '9' }
          },
          'referree' => {
            'data' => nil
          },
          'publishing-journal' => {
            'data' => nil
          },
          'comments' => {
            'data' => [
              { 'type' => 'comments', 'id' => '5' },
              { 'type' => 'comments', 'id' => '12' }
            ]
          }
        }
      }
    }
  end

  it 'works' do
    document = JSON::API.parse(@payload)

    options = {
      attributes: {
        except: [:rating]
      },
      relationships: {
        only: [:author, :'publishing-journal', :comments],
        polymorphic: [:author]
      },
      key_formatter: ->(x) { x.underscore }
    }
    actual = document.data.to_activerecord_hash(options)
    expected = {
      id: '1',
      title: 'JSON API paints my bikeshed!',
      author_id: '9',
      author_type: 'Person',
      publishing_journal_id: nil,
      comment_ids: ['5', '12']
    }

    expect(actual).to eq expected
  end

  it 'whitelists all attributes/relationships by default' do
    document = JSON::API.parse(@payload)

    actual = document.data.to_activerecord_hash
    expected = {
      id: '1',
      title: 'JSON API paints my bikeshed!',
      rating: '5 stars',
      author_id: '9',
      referree_id: nil,
      :'publishing-journal_id' => nil,
      comment_ids: ['5', '12']
    }

    expect(actual).to eq expected
  end
end
