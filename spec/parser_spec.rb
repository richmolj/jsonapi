require 'json/api'

describe JSON::API, '#parse' do
  before(:all) do
    @payload = {
      'data' => [
        {
          'type' => 'articles',
          'id' => '1',
          'attributes' => {
            'title' => 'JSON API paints my bikeshed!'
          },
          'links' => {
            'self' => 'http://example.com/articles/1'
          },
          'relationships' => {
            'author' => {
              'links' => {
                'self' => 'http://example.com/articles/1/relationships/author',
                'related' => 'http://example.com/articles/1/author'
              },
              'data' => { 'type' => 'people', 'id' => '9' }
            },
            'journal' => {
              'data' => nil
            },
            'comments' => {
              'links' => {
                'self' => 'http://example.com/articles/1/relationships/comments',
                'related' => 'http://example.com/articles/1/comments'
              },
              'data' => [
                { 'type' => 'comments', 'id' => '5' },
                { 'type' => 'comments', 'id' => '12' }
              ]
            }
          }
        }],
      'meta' => {
        'count' => '13'
      }
    }
  end

  it 'works' do
    document = JSON::API.parse(@payload)

    expect(document.meta.keys).to eq ['count']
    expect(document.meta['count']).to eq '13'
    expect(document.data.first.links.keys).to eq ['self']
    expect(document.data.first.links.defined?(:self)).to be_truthy
    expect(document.data.first.links.self.value).to eq 'http://example.com/articles/1'
    expect(document.data.first.attributes.keys).to eq ['title']
    expect(document.data.first.attributes.defined?(:title)).to be_truthy
    expect(document.data.first.attributes.title).to eq 'JSON API paints my bikeshed!'
    expect(document.data.first.relationships.keys).to eq %w(author journal comments)
    expect(document.data.first.relationships.defined?(:author)).to be_truthy
    expect(document.data.first.relationships.author.collection?).to be_falsy
    expect(document.data.first.relationships.author.data.id).to eq '9'
    expect(document.data.first.relationships.author.data.type).to eq 'people'
    expect(document.data.first.relationships.author.links.keys).to eq ['self', 'related']
    expect(document.data.first.relationships.author.links.defined?(:self)).to be_truthy
    expect(document.data.first.relationships.author.links.self.value).to eq 'http://example.com/articles/1/relationships/author'
    expect(document.data.first.relationships.author.links.defined?(:related)).to be_truthy
    expect(document.data.first.relationships.author.links.related.value).to eq 'http://example.com/articles/1/author'
    expect(document.data.first.relationships.defined?(:comments)).to be_truthy
    expect(document.data.first.relationships.comments.collection?).to be_truthy
    expect(document.data.first.relationships.comments.data.size).to eq 2
    expect(document.data.first.relationships.comments.data[0].id).to eq '5'
    expect(document.data.first.relationships.comments.data[0].type).to eq 'comments'
    expect(document.data.first.relationships.comments.data[1].id).to eq '12'
    expect(document.data.first.relationships.comments.data[1].type).to eq 'comments'
    expect(document.data.first.relationships.comments.links.keys).to eq ['self', 'related']
    expect(document.data.first.relationships.comments.links.defined?(:self)).to be_truthy
    expect(document.data.first.relationships.comments.links.self.value).to eq 'http://example.com/articles/1/relationships/comments'
    expect(document.data.first.relationships.comments.links.defined?(:related)).to be_truthy
    expect(document.data.first.relationships.comments.links.related.value).to eq 'http://example.com/articles/1/comments'
    expect(document.data.first.relationships.defined?(:journal)).to be_truthy
    expect(document.data.first.relationships.journal.collection?).to be_falsy
    expect(document.data.first.relationships.journal.data).to eq nil
  end
end
