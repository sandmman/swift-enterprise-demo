[![Build Status - Develop](https://travis-ci.com/IBM-Swift/swift-enterprise-demo.svg?token=mJT5PYB2xpM2BrzG4qWD&branch=develop)](https://travis-ci.com/IBM-Swift/swift-enterprise-demo)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)

Bluemix Demo Application for Auto-scaling, Availability Monitoring, and Alert Notification services
=+=================================================================================================

  * Linux: `swift build`
  * macOS: `swift build -Xlinker -lc++`




  ## Pushing the application to Bluemix
  ### Using the Deploy to Bluemix button
  Clicking on the button below deploys this starter application to Bluemix. The `manifest.yml` file [included in the repo] is parsed to obtain the name of the application and configuration details. For further details on the structure of the `manifest.yml` file, see the [Cloud Foundry documentation](https://docs.cloudfoundry.org/devguide/deploy-apps/manifest.html#minimal-manifest).

  <!---
  [![Deploy to Bluemix](https://bluemix.net/deploy/button.png)](https://bluemix.net/deploy)
  -->
  [![Deploy to Bluemix](https://hub.jazz.net/deploy/button.png)](https://bluemix.net/deploy?repository=https://github.com/IBM-Swift/swift-enterprise-demo.git)

  Once deployment to Bluemix is completed, you can access the route assigned to your application using the web browser of your choice. You should then see the welcome page for the SwiftEnterpriseDemo app!

  Note that the [IBM Bluemix buildpack for Swift](https://github.com/IBM-Swift/swift-buildpack) is used for the deployment of this app to Bluemix. This IBM Bluemix Runtime for Swift is currently installed in the following Bluemix regions: US South, United Kingdom, and Sydney.

  ### Using the Cloud Foundry command line
  You can also manually deploy the app to Bluemix. Though not as magical as using the Bluemix button above, manually deploying the app gives you some insights about what is happening behind the scenes. Remember that you'd need the Cloud Foundry [command line](https://www.ng.bluemix.net/docs/starters/install_cli.html) installed on your system to deploy the app to Bluemix.

  Using the Cloud Foundry command line you can get a list of the buildpacks (along with their versions) that are installed on Bluemix. Note that you should be already logged on to Bluemix before you issue any of the following commands.

  Executing the `cf buildpacks` above command should result in output similar to the following:

  ```
  $ cf buildpacks
  Getting buildpacks...

  buildpack                               position   enabled   locked   filename
  liberty-for-java                        1          true      false    buildpack_liberty-for-java_v3.7-20170118-2046.zip
  sdk-for-nodejs                          2          true      false    buildpack_sdk-for-nodejs_v3.10-20170119-1146.zip
  dotnet-core                             3          true      false    buildpack_dotnet-core_v1.0.10-20170124-1145.zip
  swift_buildpack                         4          true      false    buildpack_swift_v2.0.4-20170125-2344.zip
  java_buildpack                          5          true      false    java-buildpack-v3.6.zip
  ruby_buildpack                          6          true      false    ruby_buildpack-cached-v1.6.16.zip
  nodejs_buildpack                        7          true      false    nodejs_buildpack-cached-v1.5.11.zip
  go_buildpack                            8          true      false    go_buildpack-cached-v1.7.5.zip
  python_buildpack                        9          true      false    python_buildpack-cached-v1.5.5.zip
  php_buildpack                           10         true      false    php_buildpack-cached-v4.3.10.zip
  xpages_buildpack                        11         true      false    xpages_buildpack_v1.2.2-20170112-1328.zip
  staticfile_buildpack                    12         true      false    staticfile_buildpack-cached-v1.3.6.zip
  binary_buildpack                        13         true      false    binary_buildpack-cached-v1.0.1.zip
  liberty-for-java_v3_4_1-20161030-2241   14         true      false    buildpack_liberty-for-java_v3.4.1-20161030-2241.zip
  liberty-for-java_v3_6-20161209-1351     15         true      false    buildpack_liberty-for-java_v3.6-20161209-1351.zip
  xpages_buildpack_v1_2_1-20160913-103    16         true      false    xpages_buildpack_v1.2.1-20160913-1038.zip
  dotnet-core_v1_0_1-20161005-1225        17         true      false    buildpack_dotnet-core_v1.0.1-20161005-1225.zip
  sdk-for-nodejs_v3_9-20161128-1327       18         true      false    buildpack_sdk-for-nodejs_v3.9-20161128-1327.zip
  swift_buildpack_v2_0_3-20161217-1748    19         true      false    buildpack_swift_v2.0.3-20161217-1748.zip
  ```

  Looking at the output above, we can see that the IBM Bluemix Runtime for Swift is installed on Bluemix. This will allow a seamless deployment of the starter application to Bluemix.

  After you have cloned this Git repo, go to its root folder on your system and issue the `cf push` command:

  ```
  $ cf push
  Using manifest file /Users/olivieri/git/SwiftEnterpriseDemo/manifest.yml

  Creating app SwiftEnterpriseDemo in org roliv@us.ibm.com / space dev as roliv@us.ibm.com...
  OK

  Creating route SwiftEnterpriseDemo-unfiducial-flab.eu-gb.mybluemix.net...
  OK

  Binding SwiftEnterpriseDemo-unfiducial-flab.eu-gb.mybluemix.net to SwiftEnterpriseDemo...
  OK

  Uploading SwiftEnterpriseDemo...
  Uploading app files from: /Users/olivieri/git/SwiftEnterpriseDemo
  Uploading 110.4K, 60 files
  Done uploading               
  OK

  Starting app SwiftEnterpriseDemo in org roliv@us.ibm.com / space dev as roliv@us.ibm.com...
  -----> Downloaded app package (56K)
  -----> Default supported Swift version is 3.0
  -----> Installing system level dependencies...
  -----> Installing libblocksruntime0_0.1-1_amd64.deb
  -----> Installing libblocksruntime-dev_0.1-1_amd64.deb
  -----> Installing libcurl3_7.35.0-1ubuntu2.6_amd64.deb
  -----> Installing libkqueue0_1.0.4-2ubuntu1_amd64.deb
  -----> Installing libssl-dev_1.0.1f-1ubuntu2.19_amd64.deb
  -----> Installing openssl_1.0.1f-1ubuntu2.19_amd64.deb
  -----> Installing uuid-dev_2.20.1-5.1ubuntu20_amd64.deb
  -----> No Aptfile found.
  -----> Writing profile script...
  -----> Installing Swift 3.0
  -----> Buildpack version 2.0.0
         Downloaded Swift
  -----> Installing Clang 3.8.0
         Downloaded Clang
  -----> This buildpack does not add libdispatch binaries for swift-3.0 (note: Swift binaries from 8/23 and later already include libdispatch)
  -----> Building Package...
         Cloning https://github.com/IBM-Swift/Kitura.git
         HEAD is now at 164f5df Merge branch 'master' into automatic_migration_to_1.0.0
         Resolved version: 1.0.0
         Cloning https://github.com/IBM-Swift/Kitura-net.git
         HEAD is now at 34b6d06 updated dependency versions in Package.swift
         Resolved version: 1.0.0
         Cloning https://github.com/IBM-Swift/LoggerAPI.git
         HEAD is now at d4c1682 Regenerated API Documentation (#15)
         Resolved version: 1.0.0
         Cloning https://github.com/IBM-Swift/BlueSocket.git
         HEAD is now at 6fc0f37 Update to latest (3.0.1 BETA 1) toolchain.
         Resolved version: 0.11.11
         Cloning https://github.com/IBM-Swift/CCurl.git
         HEAD is now at 3330699 Removed use of pkgConfig and added system declaration
         Resolved version: 0.2.1
         Cloning https://github.com/IBM-Swift/CHTTPParser.git
         HEAD is now at 429eff6 Merge pull request #7 from ianpartridge/master
         Resolved version: 0.3.0
         Cloning https://github.com/IBM-Swift/BlueSSLService.git
         HEAD is now at 2d674f6 Update to latest (3.0.1 BETA 1) toolchain.
         Resolved version: 0.11.21
         Cloning https://github.com/IBM-Swift/OpenSSL.git
         Resolved version: 0.11.21
         Cloning https://github.com/IBM-Swift/OpenSSL.git
         HEAD is now at b5df08f Merge pull request #2 from preecet/master
         Resolved version: 0.2.2
         Cloning https://github.com/IBM-Swift/CEpoll.git
         HEAD is now at 111cbcb IBM-Swift/Kitura#435 Added a README.md file
         Cloning https://github.com/IBM-Swift/SwiftyJSON.git
         HEAD is now at 73b523a 3.0
         Resolved version: 14.2.0
         Cloning https://github.com/IBM-Swift/Kitura-TemplateEngine.git
         HEAD is now at f013da3 Regenerated API Documentation (#8)
         Resolved version: 1.0.0
         Cloning https://github.com/IBM-Swift/HeliumLogger.git
         HEAD is now at 4a52f0b updated dependency versions in Package.swift
         Resolved version: 1.0.0
         Cloning https://github.com/IBM-Swift/Swift-cfenv.git
         HEAD is now at 04d7d88 Update swift version to 3.0
         Resolved version: 1.7.0
         Cloning https://github.com/IBM-Bluemix/cf-deployment-tracker-client-swift.git
         HEAD is now at ea2728c Updated Package.swift - References Kitura-net official release.
         Resolved version: 0.4.0
         Compile CHTTPParser http_parser.c
         Compile CHTTPParser utils.c
         Compile Swift Module 'Socket' (3 sources)
         Compile Swift Module 'LoggerAPI' (1 sources)
         Compile Swift Module 'SwiftyJSON' (2 sources)
         Compile Swift Module 'KituraTemplateEngine' (1 sources)
         Compile Swift Module 'HeliumLogger' (1 sources)
         Compile Swift Module 'SSLService' (1 sources)
         Compile Swift Module 'KituraNet' (29 sources)
         Compile Swift Module 'CloudFoundryEnv' (7 sources)
         Compile Swift Module 'CloudFoundryDeploymentTracker' (1 sources)
         Compile Swift Module 'Kitura' (40 sources)
         Compile Swift Module 'Kitura_Starter_Bluemix' (2 sources)
         Linking ./.build/release/SwiftEnterpriseDemo
  -----> Copying dynamic libraries
  -----> Copying binaries to 'bin'
  -----> Cleaning up build files
  -----> Cleaning up cache folder

  -----> Uploading droplet (17M)

  1 of 1 instances running

  App started


  OK

  App SwiftEnterpriseDemo was started using this command `SwiftEnterpriseDemo`
  OK

  requested state: started
  instances: 1/1
  usage: 256M x 1 instances
  urls: SwiftEnterpriseDemo-unfiducial-flab.eu-gb.mybluemix.net
  last uploaded: Sat Sep 24 00:11:48 UTC 2016
  stack: cflinuxfs2
  buildpack: swift_buildpack

       state     since                    cpu    memory          disk        details
  #0   running   2016-09-23 08:14:40 PM   0.0%   18.9M of 256M   59M of 1G
  ```

  Once the application is pushed to and running on Bluemix, you can access your application route to see the welcome page for the SwiftEnterpriseDemo app. You can log on to your [Bluemix account](https://console.ng.bluemix.net) to find the route of your application or you can inspect the output from the execution of the `cf push` command.  The string value (e.g. SwiftEnterpriseDemo-unfiducial-flab.eu-gb.mybluemix.net) shown next to the urls should contain the route.  Use that route as the URL to access the sample server using the browser of your choice.
