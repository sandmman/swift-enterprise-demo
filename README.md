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

  [![Deploy to Bluemix](https://hub.jazz.net/deploy/button.png)](https://bluemix.net/deploy?repository=https://github.com/IBM-Swift/swift-enterprise-demo.git)

  Once deployment to Bluemix is completed, you can access the route assigned to your application using the web browser of your choice. You should then see the welcome page for the SwiftEnterpriseDemo app!

  Note that the [IBM Bluemix buildpack for Swift](https://github.com/IBM-Swift/swift-buildpack) is used for the deployment of this app to Bluemix. This IBM Bluemix Runtime for Swift is currently installed in the following Bluemix regions: US South, United Kingdom, and Sydney.

  ### Using the Cloud Foundry command line
  You can also manually deploy the app to Bluemix. Though not as magical as using the Bluemix button above, manually deploying the app gives you some insights about what is happening behind the scenes. Remember that you'd need the Cloud Foundry [command line](https://www.ng.bluemix.net/docs/starters/install_cli.html) installed on your system to deploy the app to Bluemix.

  Using the Cloud Foundry command line you can get a list of the buildpacks (along with their versions) that are installed on Bluemix by issuing the `cf buildpacks` command. Note that you should be already logged on to Bluemix before you issue any Cloud Foundry commands.

  After you have cloned this Git repo, go to its root folder on your system and issue the `cf push` command to deploy the application.

  Once the application is pushed to and running on Bluemix, you can access your application route to see the welcome page for the SwiftEnterpriseDemo app. You can log on to your [Bluemix account](https://console.ng.bluemix.net) to find the route of your application or you can inspect the output from the execution of the `cf push` command.  The string value shown next to the urls should contain the route.  Use that route as the URL to access the sample server using the browser of your choice.
