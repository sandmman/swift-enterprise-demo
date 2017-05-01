##
# Copyright IBM Corporation 2017
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
##

set -e

eval "sudo apt-get update"
eval "wget -q -O - https://packages.cloudfoundry.org/debian/cli.cloudfoundry.org.key | sudo apt-key add -"
eval "echo \"deb http://packages.cloudfoundry.org/debian stable main\" | sudo tee /etc/apt/sources.list.d/cloudfoundry-cli.list"
eval "sudo apt-get install cf-cli=6.26.0"
eval "cf login -a https://$BLUEMIX_REGION -u $BLUEMIX_USER -p $BLUEMIX_PASS -s applications-dev -o $BLUEMIX_USER"
TOKEN=$(cf oauth_token)

if [[ $TRAVIS_BRANCH = "master" ]]; then
    echo "Building project with 'production' credentials..."
    ./Package-Builder/build-package.sh -projectDir $TRAVIS_BUILD_DIR -credentialsDir $TRAVIS_BUILD_DIR/Testing-Credentials/SwiftEnterpriseDemo/production
else
    echo "Building project with 'development' credentials..."
    ./Package-Builder/build-package.sh -projectDir $TRAVIS_BUILD_DIR -credentialsDir $TRAVIS_BUILD_DIR/Testing-Credentials/SwiftEnterpriseDemo/development
fi

eval "sed -i '' -e 's/<token>/$TOKEN/' ../cloud_config.json"
