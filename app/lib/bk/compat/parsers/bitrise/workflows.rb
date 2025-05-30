# frozen_string_literal: true

require_relative 'env_helper'

module BK
  module Compat
    # Bitrise translation of workflows
    class Bitrise
      private

      def parse_workflow(wf_name, wf_config)
        stack_value = wf_config.dig('meta', 'bitrise.io', 'stack')
        agents = stack_value ? { stack: stack_value } : {}
        cmd_step = BK::Compat::CommandStep.new(label: wf_name, key: wf_name, agents: agents)
        wf_config['steps'].each do |step|
          step_key, step_config = step.first
          cmd_step << translate_step(step_key, step_config)
        end
        cmd_step.env.merge!(BK::Compat::Bitrise::EnvHelper.process_env_variables(wf_config['envs']))
        cmd_step
      end

      def translate_step(step_key, step_config)
        step_inputs = (step_config['inputs'] || {}).reduce({}, :merge)
        load_workflow_step(step_key, step_inputs).tap do |translated_step|
          if translated_step.respond_to?(:agents) && step_config.include?('stack')
            translated_step.agents ||= {}
            translated_step.agents[:stack] = step_config['stack']
          end
        end
      end

      def load_workflow_step(step_key, step_inputs)
        step_key_normalized = step_key.split('@').first
        # Translate step with normalized key (for translator) and its input configuration
        @translator.translate_step(step_key_normalized, step_inputs)
      end
    end
  end
end
