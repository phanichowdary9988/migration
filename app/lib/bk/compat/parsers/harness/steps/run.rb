# frozen_string_literal: true

require_relative '../../../pipeline/step'

module BK
  module Compat
    module HarnessSteps
      # Implementation of native step translation
      class Translator
        def translate_run(name:, identifier:, spec:, **_rest)
          base_step(name, identifier, spec)
        end

        def base_step(name, identifier, spec)
          cmd = BK::Compat::CommandStep.new(
            label: name,
            key: identifier,
            commands: [spec['command']]
          )

          post_keys(spec).each { |k| cmd << k }
          cmd
        end

        def post_keys(spec)
          [
            translate_image(spec['image'])
          ]
        end

        def translate_image(image)
          return nil if image.nil?
          
          BK::Compat::Plugin.new(
            name: 'docker',
            config: {
              'image' => image
            }.compact
          )
        end
      end
    end
  end
end
