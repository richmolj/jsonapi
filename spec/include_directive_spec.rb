require 'json/api/include_directive'

describe JSON::API::IncludeDirective, '.key?' do
  it 'handles existing keys' do
    str = 'posts.comments'
    include_directive = JSON::API::IncludeDirective.new(str)

    expect(include_directive.key?(:posts)).to be_truthy
  end

  it 'handles absent keys' do
    str = 'posts.comments'
    include_directive = JSON::API::IncludeDirective.new(str)

    expect(include_directive.key?(:author)).to be_falsy
  end

  it 'handles wildcards' do
    str = 'posts.*'
    include_directive = JSON::API::IncludeDirective.new(
      str, allow_wildcard: true)

    expect(include_directive[:posts].key?(:author)).to be_truthy
    expect(include_directive[:posts][:author].key?(:comments)).to be_falsy
  end

  it 'handles wildcards' do
    str = 'posts.**'
    include_directive = JSON::API::IncludeDirective.new(
      str, allow_wildcard: true)

    expect(include_directive[:posts].key?(:author)).to be_truthy
    expect(include_directive[:posts][:author].key?(:comments)).to be_truthy
  end
end

describe JSON::API::IncludeDirective, '.to_string' do
  it 'works' do
    str = 'friends,comments.author,posts.author,posts.comments.author'
    include_directive = JSON::API::IncludeDirective.new(str)
    expected = include_directive.to_hash
    actual = JSON::API::IncludeDirective.new(include_directive.to_string)
                                        .to_hash

    expect(actual).to eq expected
  end
end
