[![Build Status - Master](https://travis-ci.com/IBM-Swift/swift-enterprise-demo.svg?token=mJT5PYB2xpM2BrzG4qWD&branch=master)](https://travis-ci.com/IBM-Swift/swift-enterprise-demo)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)

Bluemix Demo Application for Auto-scaling, Availability Monitoring, and Alert Notification services
===================================================================================================
 
 This application is a browser-based demo app designed to showcase the functionality of several Swift-based IBM services:
 
 * Auto-Scaling
 * IBM Alert Notification
 * Circuit Breaker
 * SwiftMetrics
 
 Certain elements of the application will cause stress on the machine running it, by design. The application requires a Bluemix account in order to deploy the application to Bluemix and utilize the services it requires. The Auto-Scaling service is a paid service and may incur charges if used by something other than an IBM developer account.
 
 # Deploying the application
 
## Initial setup
 
 There are two different repositories that need to be cloned in order to use this application. Run the following two commands, making sure you have access to both of the repos referenced here:

    git clone https://github.com/IBM-Swift/swift-enterprise-demo.git
    git clone https://github.com/IBM-Swift/Testing-Credentials.git
 
 The `Testing-Credentials` repository includes credentials that allow the application's services to work correctly. Copy those credentials over with the following command:
 
    cp Testing-Credentials/swift-enterprise-demo/development/cloud_config.json swift-enterprise-demo
 
 If you have not created the two needed services for this application (IBM Alert Notification and Auto-Scaling), a script has been provided to create these services. However, you will need to obtain a set of credentials for the Alert Notification service and place the updated `name` and `password` fields into `cloud_config.json`. The script can be run like so:
 
    Cloud-Scripts/cloud-foundry/services.sh
 
 If you want to test the IBM Alert Notification service, make sure to go to the Bluemix dashboard and create an auto-scaling policy, as alerts will not be sent if no policy is defined.

## Running the application locally
 
 In order to build the application locally, use the appropriate command depending on the operating system:

  * Linux: `swift build`
  * macOS: `swift build -Xlinker -lc++`

  ## Pushing the application to Bluemix
  ### Using the Deploy to Bluemix button
  Clicking on the button below deploys this application to Bluemix. The `manifest.yml` file [included in the repo] is parsed to obtain the name of the application and configuration details. For further details on the structure of the `manifest.yml` file, see the [Cloud Foundry documentation](https://docs.cloudfoundry.org/devguide/deploy-apps/manifest.html#minimal-manifest).

  [![Deploy to Bluemix](https://hub.jazz.net/deploy/button.png)](https://bluemix.net/deploy?repository=https://github.com/IBM-Swift/swift-enterprise-demo.git)

  Once deployment to Bluemix is completed, you can access the route assigned to your application using the web browser of your choice. You should then see the welcome page for the SwiftEnterpriseDemo app!

  Note that the [IBM Bluemix buildpack for Swift](https://github.com/IBM-Swift/swift-buildpack) is used for the deployment of this app to Bluemix. This IBM Bluemix Runtime for Swift is currently installed in the following Bluemix regions: US South, United Kingdom, and Sydney.

  ### Using the Cloud Foundry command line
  You can also manually deploy the app to Bluemix. Though not as magical as using the Bluemix button above, manually deploying the app gives you some insights about what is happening behind the scenes. Remember that you'd need the Cloud Foundry [command line](https://www.ng.bluemix.net/docs/starters/install_cli.html) installed on your system to deploy the app to Bluemix.

  After you have completed the steps in the "Initial setup" section, go to the project's root folder on your system and issue the `cf push` command to deploy the application.

  Once the application is pushed to and running on Bluemix, you can access your application route to see the welcome page for the SwiftEnterpriseDemo app. You can log on to your [Bluemix account](https://console.ng.bluemix.net) to find the route of your application or you can inspect the output from the execution of the `cf push` command.  The string value shown next to the urls should contain the route.  Use that route as the URL to access the sample server using the browser of your choice.
