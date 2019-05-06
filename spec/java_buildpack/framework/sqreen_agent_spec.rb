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

require 'spec_helper'
require 'component_helper'
require 'java_buildpack/framework/sqreen_agent'

describe JavaBuildpack::Framework::SqreenAgent do
  include_context 'with component help'

  let(:configuration) do
    { 'default_application_name' => nil }
  end

  it 'does not detect without sqreen service' do
    expect(component.detect).to be_nil
  end

  context do

    before do
      allow(services).to receive(:one_service?).with(/sqreen/, 'TOKEN_KEY')
                                               .and_return(true)
    end

    it 'detects with sqreen service' do
      expect(component.detect).to eq("sqreen-agent=#{version}")
    end

    it 'downloads SQREEN agent JAR',
       cache_fixture: 'stub-sqreen-agent.jar' do

      component.compile

      expect(sandbox + "sqreen_agent-#{version}.jar").to exist
    end

    it 'copies resources',
       cache_fixture: 'stub-sqreen-agent.jar' do

      component.compile

      expect(sandbox + 'AI-Agent.xml').to exist
    end

    it 'updates JAVA_OPTS' do
      allow(services).to receive(:find_service)
        .and_return('credentials' => { 'sqreen.token' => 'test-instrumentation-key' })

      component.release

      expect(java_opts).to include('-javaagent:$PWD/.java-buildpack/sqreen_agent/' \
                                   "sqreen_agent-#{version}.jar")
      expect(java_opts).to include('-Dsqreen.token=test-instrumentation-key')
    end

  end

end
