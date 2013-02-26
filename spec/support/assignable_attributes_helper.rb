require 'active_support/concern'

module AssignableAttributesHelper
  extend ActiveSupport::Concern

  module ClassMethods
    # A helper method for checking if an Object has an assignable attribute
    # (i.e. that object.foo = 'bar' changes object.foo to 'bar')
    def it_should_have_assignable_attributes(*attributes)
      attributes.each do |attribute|
        let(:new_value) { double 'new value' }

        specify do
          expect { subject.public_send("#{attribute}=", new_value) }.to \
            change { subject.public_send(attribute) }.to(new_value)
        end
      end
    end
  end
end
