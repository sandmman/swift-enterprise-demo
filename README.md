[![Build Status - Develop](https://travis-ci.com/IBM-Swift/swift-enterprise-demo.svg?token=mJT5PYB2xpM2BrzG4qWD&branch=develop)](https://travis-ci.com/IBM-Swift/swift-enterprise-demo)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)

# Swift-Enterprise-Demo
Swift-Enterprise-Demo is designed to showcase new enterprise capabilities that you can leverage when you deploy your Swift applications to Bluemix. Specifically, this application showcases the following Bluemix services and new libraries for the Swift language:

* Auto Scaling
* Alert Notification
* Bluemix Availability Monitoring (BAM)
* Circuit Breaker

Using Swift-Enterprise-Demo you can see how the application can scale in and out according to rules defined in the Auto Scaling service, see how metrics such as CPU usage, memory usage, and network usage change in the Bluemix Availability Monitoring dashboard, receive alerts when important events occur, and see how the Circuit Breaker pattern prevents the application from executing actions that are bound to fail.

The browser-based component of this application provides UI widgets that you can use to trigger actions that will cause stress on the system running the application. These actions can increase or decrease the memory usage, increase or decrease the HTTP response time by adding or removing a delay, and increase or decrease the number of HTTP requests per second.

## Swift version
The latest version of Swift-Enterprise-Demo works with the `3.0.2` version of the Swift binaries. You can download this version of the Swift binaries by following this [link](https://swift.org/download/#snapshots).

## Deploying the application to Bluemix
### Using the Deploy to Bluemix button
Clicking on the button below deploys this application to Bluemix. The `manifest.yml` file [included in the repo] is parsed to obtain the name of the application and configuration details. For further details on the structure of the `manifest.yml` file, see the [Cloud Foundry documentation](https://docs.cloudfoundry.org/devguide/deploy-apps/manifest.html#minimal-manifest).

[![Deploy to Bluemix](https://hub.jazz.net/deploy/button.png)](https://bluemix.net/deploy?repository=https://github.com/IBM-Swift/swift-enterprise-demo.git)

Once deployment to Bluemix is completed, you can access the route assigned to your application using the web browser of your choice. You should then see the welcome page for the SwiftEnterpriseDemo app!

Note that the [IBM Bluemix buildpack for Swift](https://github.com/IBM-Swift/swift-buildpack) is used for the deployment of this app to Bluemix. This IBM Bluemix Runtime for Swift is currently installed in the following Bluemix regions: US South, United Kingdom, and Sydney.

### Using the Cloud Foundry command line
You can also manually deploy the Swift-Enterprise-Demo app to Bluemix. Though not as magical as using the Bluemix button above, manually deploying the app gives you some insights about what is happening behind the scenes. Remember that you'd need the Cloud Foundry [command line](https://www.ng.bluemix.net/docs/starters/install_cli.html) installed on your system to deploy the app to Bluemix.

Execute the following command to clone the Git repository:

```bash
git clone https://github.com/IBM-Swift/swift-enterprise-demo
```

Go to the project's root folder on your system and execute the `Cloud-Scripts/cloud-foundry/services.sh` script to create the services Swift-Enterprise-Demo will use. Please note that you should have logged on to Bluemix before attempting to execute this script. For information on how to log in, see the Cloud Foundry command line [documentation](https://docs.cloudfoundry.org/cf-cli/getting-started.html).

Executing the `Cloud-Scripts/cloud-foundry/services.sh` script should result in output similar to this:

```bash
$ Cloud-Scripts/cloud-foundry/services.sh
Creating services...
Creating service instance SwiftEnterpriseDemo-Alert in org roliv@us.ibm.com / space dev as roliv@us.ibm.com...
OK

Attention: The plan `authorizedusers` of service `alertnotification` is not free.  The instance `SwiftEnterpriseDemo-Alert` will incur a cost.  Contact your administrator if you think this is in error.

Creating service instance SwiftEnterpriseDemo-Auto-Scaling in org roliv@us.ibm.com / space dev as roliv@us.ibm.com...
OK
```

Once the services have been created, you can issue the `cf push` command from the project's root folder to deploy the application. Once the application is pushed to and running on Bluemix, you can access your application assigned URL (i.e. route). You can log on to your [Bluemix account](https://console.ng.bluemix.net) to find the route of your application or you can inspect the output from the execution of the `cf push` command.  The string value shown next to the urls should contain the route.  Use that route as the URL to access the sample server using the browser of your choice.


## Running the application locally

 In order to build the application locally, use the appropriate command depending on the operating system:

  * Linux: `swift build`
  * macOS: `swift build -Xlinker -lc++`







  There are two different repositories that need to be cloned in order to use this application. Run the following two commands, making sure you have access to both of the repos referenced here:

      git clone https://github.com/IBM-Swift/swift-enterprise-demo.git
      git clone https://github.com/IBM-Swift/Testing-Credentials.git

   The `Testing-Credentials` repository includes credentials that allow the application's services to work correctly. Copy those credentials over with the following command:

      cp Testing-Credentials/swift-enterprise-demo/development/cloud_config.json swift-enterprise-demo

   If you have not created the two needed services for this application (IBM Alert Notification and Auto-Scaling), a script has been provided to create these services. However, you will need to obtain a set of credentials for the Alert Notification service and place the updated `name` and `password` fields into `cloud_config.json`. The script can be run like so:

      Cloud-Scripts/cloud-foundry/services.sh

   If you want to test the IBM Alert Notification service, make sure to go to the Bluemix dashboard and create an auto-scaling policy, as alerts will not be sent if no policy is defined.
