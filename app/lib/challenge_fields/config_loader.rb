# frozen_string_literal: true

module ChallengeFields
  class ConfigLoader
    DEFAULT_CONFIG_PATH = Rails.root.join("config", "challenge_fields.yml").freeze
    DEFAULT_GROUP_KEY = "_default"

    FieldTypeConfig = Struct.new(:type, :defaults, keyword_init: true) do
      def to_h
        { type: type, defaults: defaults }
      end
    end

    class << self
      def load(path = DEFAULT_CONFIG_PATH)
        new(path)
      end

      def default
        @default ||= load
      end

      def reset!
        @default = nil
      end
    end

    attr_reader :config_path

    def initialize(config_path)
      @config_path = config_path
      @config_data = nil
      @field_types_cache = {}
    end

    def field_types_for(challenge_type_code)
      code = challenge_type_code.to_s.presence || DEFAULT_GROUP_KEY

      @field_types_cache[code] ||= begin
        raw_configs = config_data[code] || config_data[DEFAULT_GROUP_KEY] || []
        raw_configs.map { |config| parse_field_config(config) }
      end
    end

    def all_field_types
      config_data.values.flatten.map { |c| c["type"].to_sym }.uniq
    end

    def options_for_select(challenge_type_code = nil)
      field_types = field_types_for(challenge_type_code)

      field_types.map do |config|
        definition = Registry.definition_for(config.type)
        [definition.name, config.type]
      end
    end

    def defaults_for(challenge_type_code, field_type)
      field_configs = field_types_for(challenge_type_code)
      config = field_configs.find { |c| c.type.to_sym == field_type.to_sym }
      config&.defaults || {}
    end

    def field_type_available?(challenge_type_code, field_type)
      field_configs = field_types_for(challenge_type_code)
      field_configs.any? { |c| c.type.to_sym == field_type.to_sym }
    end

    def reload!
      @config_data = nil
      @field_types_cache = {}
      config_data
    end

    private

    def config_data
      @config_data ||= load_config_file
    end

    def load_config_file
      return {} unless File.exist?(config_path)

      content = File.read(config_path)
      YAML.safe_load(content, permitted_classes: [], permitted_symbols: [], aliases: true) || {}
    rescue Psych::SyntaxError => e
      Rails.logger.error("Failed to parse challenge fields config: #{e.message}")
      {}
    end

    def parse_field_config(config)
      config = config.deep_stringify_keys

      FieldTypeConfig.new(
        type: config["type"].to_sym,
        defaults: (config["defaults"] || {}).deep_symbolize_keys
      )
    end
  end
end
