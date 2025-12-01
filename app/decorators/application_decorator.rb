# frozen_string_literal: true

class ApplicationDecorator
  attr_reader :object

  delegate :id, :to_param, :to_key, :to_model, :persisted?, :new_record?, :errors, to: :object

  def initialize(object)
    @object = object
  end

  def to_model
    object
  end

  def method_missing(method_name, ...)
    if object.respond_to?(method_name)
      object.public_send(method_name, ...)
    else
      super
    end
  end

  def respond_to_missing?(method_name, include_private = false)
    object.respond_to?(method_name, include_private) || super
  end

  def inspect
    "#<#{self.class.name} object: #{object.inspect}>"
  end
end
