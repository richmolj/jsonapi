require 'active_support/core_ext/string/inflections'

module JSON
  module API
    class Resource
      # Transform the resource object into a hash ready for ActiveRecord's
      # new/create/update.
      #
      # @example
      #   payload = {
      #     'data' => {
      #       'type' => 'articles',
      #       'id' => '1',
      #       'attributes' => {
      #         'title' => 'JSON API paints my bikeshed!',
      #         'rating' => '5 stars'
      #       },
      #       'relationships' => {
      #         'author' => {
      #           'data' => { 'type' => 'people', 'id' => '9' }
      #         },
      #         'referree' => {
      #           'data' => nil
      #         },
      #         'publishing-journal' => {
      #           'data' => nil
      #         },
      #         'comments' => {
      #           'data' => [
      #             { 'type' => 'comments', 'id' => '5' },
      #             { 'type' => 'comments', 'id' => '12' }
      #           ]
      #         }
      #       }
      #     }
      #   }
      #   document = JSON::API.parse(payload)
      #   options = {
      #     attributes: {
      #       except: [:rating]
      #     },
      #     relationships: {
      #       only: [:author, :'publishing-journal', :comments],
      #       polymorphic: [:author]
      #     },
      #     key_formatter: ->(x) { x.underscore }
      #   }
      #   document.data.to_activerecord_hash(options)
      #   # => {
      #          id: '1',
      #          title: 'JSON API paints my bikeshed!',
      #          author_id: '9',
      #          author_type: 'people',
      #          publishing_journal_id: nil,
      #          comment_ids: ['5', '12']
      #        }
      #
      # @param options [Hash]
      #   * :attributes (Hash)
      #     * :only (Array<Symbol,String>)
      #     * :except (Array<Symbol,String>)
      #   * :relationships (Hash)
      #     * :only (Array<Symbol,String>)
      #     * :except (Array<Symbol,String>)
      #     * :polymorphic (Array<Symbol,String>)
      #   * :key_formatter (lambda)
      # @return [Hash]
      def to_activerecord_hash(options = {})
        hash = {}
        hash[:id] = id unless id.nil?
        hash.merge!(attributes_for_activerecord_hash(options))
        hash.merge!(relationships_for_activerecord_hash(options))

        hash
      end

      private

      def attributes_for_activerecord_hash(options)
        attributes_hashes =
          filter_keys(attributes.keys, options[:attributes]).map do |key|
            attribute_for_activerecord_hash(key, options[:key_formatter])
          end

        attributes_hashes.reduce({}, :merge)
      end

      def attribute_for_activerecord_hash(key, key_formatter)
        { format_key(key, key_formatter).to_sym => attributes[key] }
      end

      def relationships_for_activerecord_hash(options)
        relationship_hashes =
          filter_keys(relationships.keys, options[:relationships]).map do |key|
            polymorphic = (options[:relationships][:polymorphic] || [])
                          .include?(key.to_sym)
            relationship_for_activerecord_hash(key,
                                               options[:key_formatter],
                                               polymorphic)
          end

        relationship_hashes.reduce({}, :merge)
      end

      def relationship_for_activerecord_hash(rel_name,
                                             key_formatter,
                                             polymorphic)
        rel = relationships[rel_name]
        key = format_key(rel_name, key_formatter)

        if rel.collection?
          to_many_relationship_for_activerecord_hash(key, rel)
        else
          to_one_relationship_for_activerecord_hash(key, rel, polymorphic)
        end
      end

      def to_many_relationship_for_activerecord_hash(key, rel)
        { "#{key.singularize}_ids".to_sym => rel.data.map(&:id) }
      end

      def to_one_relationship_for_activerecord_hash(key, rel, polymorphic)
        value = rel.data ? rel.data.id : nil
        hash = { "#{key}_id".to_sym => value }
        if polymorphic && !rel.data.nil?
          hash["#{key}_type".to_sym] = rel.data.type.singularize.capitalize
        end

        hash
      end

      def format_key(key, key_formatter)
        if key_formatter
          key_formatter.call(key)
        else
          key
        end
      end

      def filter_keys(keys, filter)
        if filter[:only]
          keys & filter[:only].map(&:to_s)
        elsif filter[:except]
          keys - filter[:except].map(&:to_s)
        else
          keys
        end
      end
    end
  end
end
