[![Build Status - Develop](https://travis-ci.com/IBM-Swift/swift-enterprise-demo.svg?token=mJT5PYB2xpM2BrzG4qWD&branch=develop)](https://travis-ci.com/IBM-Swift/swift-enterprise-demo)
![macOS](https://img.shields.io/badge/os-macOS-green.svg?style=flat)
![Linux](https://img.shields.io/badge/os-linux-green.svg?style=flat)

# Swift-Enterprise-Demo
Swift-Enterprise-Demo is designed to highlight new enterprise capabilities that you can leverage when you deploy your Swift applications to Bluemix. Specifically, this application showcases the following Bluemix services and new libraries for the Swift language:

* Auto Scaling
* Alert Notification
* Bluemix Availability Monitoring (BAM)
* Circuit Breaker
* SwiftMetrics

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

After the services are created, you can issue the `cf push` command from the project's root folder to deploy the application to Bluemix. Once the application is running on Bluemix, you can access your application assigned URL (i.e. route). To find the route, you can log on to your [Bluemix account](https://console.ng.bluemix.net), or you can inspect the output from the execution of the `cf push` or `cf apps` commands. The string value shown next to (or below) the `urls` field contains the assigned route.  Use that route as the URL to access the sample server using the browser of your choice.

## Configuring the application
The `cloud_config.json` configuration file is found in the root folder of the application's repository. This file needs to be updated before you can make use of the application.

```bash
$ cat cloud_config.json
{ "name": "SwiftEnterpriseDemo",
  "cf-oauth-token": "<token>",
  "microservice-url": "<microservice-url>",
  "vcap": {
    "services": {
      "alertnotification": [
        {
          "name": "SwiftEnterpriseDemo-Alert",
          "label": "alertnotification",
          "plan": "authorizedusers",
          "credentials": {
            "url": "<url>",
            "name": "<name>",
            "password": "<password>",
            "swaggerui": "https://ibmnotifybm.mybluemix.net/docs/alerts/v1"
          }
        }
      ]
    }
  }
}
```

You should obtain the credentials for the [IBM Alert Notification](https://console.ng.bluemix.net/docs/services/AlertNotification/index.html) service instance you created earlier and update the values for the `url`, `name`, and `password` fields accordingly. To obtain these credentials, you can access the application's dashboard on Bluemix.

You also need to obtain a Cloud Foundry OAuth authentication token and update the value for the `cf-oauth-token` field. To obtain this token, you can execute the following command:

```bash
$ cf oauth-token
bearer <token string>
```

Make sure you include the `bearer` keyword along with the token when you update the value for the `cf-oauth-token` field.

To update the value for the `microservice-url` field, you should provision an instance of the [Kitura-Starter](https://github.com/IBM-Bluemix/Kitura-Starter) application on Bluemix and obtain the URL (i.e. route) assigned to it. For example, say that `kitura-starter-educated-spectacular.mybluemix.net` is the assigned URL to an instance of the Kitura-Starter application provisioned on Bluemix, then that's the value you should assign to the `microservice-url` field in the `cloud_config.json` configuration file.

Finally, you should also create [Auto-Scaling](https://console.ng.bluemix.net/docs/services/Auto-Scaling/index.html) policies to ensure that alerts are sent from the application and to leverage the scaling capabilities provided by this service. We recommend creating the following Auto-Scaling rules for the Swift-Enterprise-Demo:

TODO: Include image here

Once you've updated the `cloud_config.json` configuration file, you should update your application instance of Swift-Enterprise-Demo on Bluemix. To do, you should execute the `cf push` command from the root folder of the applications's repo.

TODO: Add output for cf push

## Running the application locally
In order to build the application locally, use the appropriate command depending on the operating system you are running on your development system:

* Linux: `swift build`
* macOS: `swift build -Xlinker -lc++`

TODO: Add content for SwiftMetrics
