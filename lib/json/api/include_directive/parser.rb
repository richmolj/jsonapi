require 'active_support/core_ext/hash/deep_merge'
module JSON
  module API
    class IncludeDirective
      # Utilities to create an IncludeDirective hash from various types of
      # inputs.
      module Parser
        module_function

        # @api private
        def parse_include_args(include_args)
          case include_args
          when Symbol
            { include_args => {} }
          when Hash
            parse_hash(include_args)
          when Array
            parse_array(include_args)
          when String
            parse_string(include_args)
          else
            {}
          end
        end

        # @api private
        def parse_string(include_string)
          include_string.split(',')
                        .map(&:strip)
                        .each_with_object({}) do |path, hash|
            hash.deep_merge!(parse_path_string(path))
          end
        end

        # @api private
        def parse_path_string(include_path)
          include_path.split('.')
                      .reverse
                      .reduce({}) { |a, e| { e.to_sym => a } }
        end

        # @api private
        def parse_hash(include_hash)
          include_hash.each_with_object({}) do |(key, value), hash|
            hash[key.to_sym] = parse_include_args(value)
          end
        end

        # @api private
        def parse_array(include_array)
          include_array.each_with_object({}) do |x, hash|
            hash.deep_merge!(parse_include_args(x))
          end
        end
      end
    end
  end
end
