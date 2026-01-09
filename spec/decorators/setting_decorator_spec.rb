# frozen_string_literal: true

require "rails_helper"

RSpec.describe SettingDecorator do
  describe "#display_key" do
    it "returns titleized key without underscores" do
      instance = decorated_instance_double(Setting, key: "site_name")

      expect(instance.display_key).to eq "Site Name"
    end

    it "handles complex keys" do
      instance = decorated_instance_double(Setting, key: "max_login_attempts")

      expect(instance.display_key).to eq "Max Login Attempts"
    end
  end

  describe "#display_value" do
    context "when value is a boolean true" do
      it "returns 'Yes'" do
        object = instance_double(Setting, boolean?: true, typed_value: true, value: "true")
        instance = SettingDecorator.new(object)

        expect(instance.display_value).to eq "Yes"
      end
    end

    context "when value is a boolean false" do
      it "returns 'No'" do
        object = instance_double(Setting, boolean?: true, typed_value: false, value: "false")
        instance = SettingDecorator.new(object)

        expect(instance.display_value).to eq "No"
      end
    end

    context "when value is blank" do
      it "returns '(not set)'" do
        object = instance_double(Setting, boolean?: false, value: "")
        instance = SettingDecorator.new(object)

        expect(instance.display_value).to eq "(not set)"
      end
    end

    context "when value is rich text" do
      it "strips HTML and truncates" do
        html_value = "<p>This is <strong>rich</strong> text content with &nbsp; special chars.</p>"
        object = instance_double(Setting, boolean?: false, rich_text?: true, multiline?: false, value: html_value)
        instance = SettingDecorator.new(object)

        result = instance.display_value
        expect(result).not_to include("<p>")
        expect(result).not_to include("<strong>")
        expect(result).to include("rich")
      end
    end

    context "when value is multiline" do
      it "truncates the value" do
        long_value = "A" * 200
        object = instance_double(Setting, boolean?: false, rich_text?: false, multiline?: true, value: long_value)
        instance = SettingDecorator.new(object)

        result = instance.display_value
        expect(result.length).to eq 100
        expect(result).to end_with("...")
      end
    end

    context "when value is regular string" do
      it "returns the value as-is" do
        object = instance_double(Setting, boolean?: false, rich_text?: false, multiline?: false, value: "simple value")
        instance = SettingDecorator.new(object)

        expect(instance.display_value).to eq "simple value"
      end
    end
  end

  describe "#group_badge_class" do
    context "when group is 'general'" do
      it "returns blue badge classes" do
        instance = decorated_instance_double(Setting, group: "general")

        expect(instance.group_badge_class).to include("blue")
      end
    end

    context "when group is 'appearance'" do
      it "returns purple badge classes" do
        instance = decorated_instance_double(Setting, group: "appearance")

        expect(instance.group_badge_class).to include("purple")
      end
    end

    context "when group is 'content'" do
      it "returns emerald badge classes" do
        instance = decorated_instance_double(Setting, group: "content")

        expect(instance.group_badge_class).to include("emerald")
      end
    end

    context "when group is 'notifications'" do
      it "returns amber badge classes" do
        instance = decorated_instance_double(Setting, group: "notifications")

        expect(instance.group_badge_class).to include("amber")
      end
    end

    context "when group is unknown" do
      it "returns slate badge classes" do
        instance = decorated_instance_double(Setting, group: "unknown")

        expect(instance.group_badge_class).to include("slate")
      end
    end
  end

  describe "#type_label" do
    it "returns titleized value_type" do
      instance = decorated_instance_double(Setting, value_type: "string")

      expect(instance.type_label).to eq "String"
    end

    it "handles multi-word types" do
      instance = decorated_instance_double(Setting, value_type: "rich_text")

      expect(instance.type_label).to eq "Rich Text"
    end
  end
end
