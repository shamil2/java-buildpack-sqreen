# frozen_string_literal: true

# Cloud Foundry Java Buildpack
# Copyright 2013-2019 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'fileutils'
require 'java_buildpack/component/versioned_dependency_component'
require 'java_buildpack/framework'

module JavaBuildpack
  module Framework

    # Encapsulates the functionality for enabling Sqreen support.
    class SqreenAgent < JavaBuildpack::Component::VersionedDependencyComponent

      # (see JavaBuildpack::Component::BaseComponent#compile)
      def compile
        download_jar
      end

      # (see JavaBuildpack::Component::BaseComponent#release)
      def release
        credentials = @application.services.find_service(FILTER, TOKEN_KEY)['credentials']

        @droplet
          .java_opts.add_javaagent(@droplet.sandbox + jar_name)
          .add_system_property('sqreen.token', credentials[TOKEN_KEY])
      end

      protected

      # (see JavaBuildpack::Component::VersionedDependencyComponent#supports?)
      def supports?
        @application.services.one_service? FILTER, TOKEN_KEY
      end

      FILTER = /sqreen/.freeze

      TOKEN_KEY = 'TOKEN_KEY'

      private_constant :FILTER, :TOKEN_KEY

    end

  end
end
