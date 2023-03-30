module TransformationParams
  extend ActiveSupport::Concern

  included do
    helpers do
      def snakerize
        request.params.deep_transform_keys!(&:underscore)
      end
    end
  end
end
