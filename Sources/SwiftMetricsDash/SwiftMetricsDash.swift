/**
* Copyright IBM Corporation 2016
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
**/

import Kitura
import HeliumLogger
import SwiftMetricsKitura
import SwiftMetrics
import SwiftyJSON
import KituraNet
import Foundation
import CloudFoundryEnv
import LoggerAPI

public class SwiftMetricsDash {

	var router:Router
	var cpuDataStore:[JSON] = []
	var httpDataStore:[JSON] = []
	var memDataStore:[JSON] = []
    var httpURLData:[String:(totalTime:Double, numHits:Double)] = [:]
	var cpuData:[CPUData] = []
	var httpData:[HTTPData] = []

	var monitor:SwiftMonitor
	var SM:SwiftMetrics
    
    public init(getHandlers: [String: RouterHandler]? = nil, postHandlers: [String: RouterHandler]? = nil, deleteHandlers: [String: RouterHandler]? = nil, putHandlers: [String: RouterHandler]? = nil) throws {
        Log.logger = HeliumLogger()
        router = Router()
        let fm = FileManager.default
        let currentDir = fm.currentDirectoryPath
        
        // Implement the passed-in handlers.
        if let getHandlers = getHandlers {
            for (route, handler) in getHandlers {
                router.get(route, handler: handler)
            }
        }
        if let postHandlers = postHandlers {
            for (route, handler) in postHandlers {
                router.post(route, handler: handler)
            }
        }
        if let deleteHandlers = deleteHandlers {
            for (route, handler) in deleteHandlers {
                router.delete(route, handler: handler)
            }
        }
        if let putHandlers = putHandlers {
            for (route, handler) in putHandlers {
                router.put(route, handler: handler)
            }
        }
        
        var workingPath = ""
        if currentDir.contains(".build") {
            //we're below the Packages directory
            workingPath = currentDir
        } else {
            //we're above the Packages directory
            workingPath = CommandLine.arguments[0]
        }
        
        let i = workingPath.range(of: ".build")
        var packagesPath = ""
        if i == nil {
            // we could be in
            packagesPath="/home/vcap/app/"
        } else {
            packagesPath = workingPath.substring(to: i!.lowerBound)
        }
        packagesPath.append("Packages/")
        
        let dirContents = try fm.contentsOfDirectory(atPath: packagesPath)
        for dir in dirContents {
            if dir.contains("SwiftMetricsDash") {
                packagesPath.append("\(dir)/public")
            }
        }
        
        router.all("/swiftdash", middleware: StaticFileServer(path: packagesPath))
        
        self.SM = try SwiftMetrics()
        _ = SwiftMetricsKitura(swiftMetricsInstance: SM)
        
        self.monitor=SM.monitor()
        
        
        router.get("/cpuRequest", handler: getcpuRequest)
        router.get("/memRequest", handler: getmemRequest)
        router.get("/envRequest", handler: getenvRequest)
        router.get("/httpRate", handler: gethttpRate)
        router.get("/cpuAverages", handler: getcpuAverages)
        router.get("/httpRequest", handler: gethttpRequest)
        router.get("/httpAverages", handler: gethttpAverages)
        
        
        monitor.on(storeCPU)
        monitor.on(storeMem)
        monitor.on(storeHTTP)
        
        try Kitura.addHTTPServer(onPort: CloudFoundryEnv.getAppEnv().port, with: router)
        Kitura.run()
    }


	func calculateHTTPRate() -> JSON {
		var rate = 0.0
		var last = 0
		let tempArray = self.httpData
		if (tempArray.count > 0) {
			let first = tempArray[0].timeOfRequest
			last = tempArray[tempArray.count-1].timeOfRequest
			if (last-first > 0) {
				rate = (Double(tempArray.count * 1000))/(Double(last-first))
			}
		}
		return JSON(["httpRate":"\(rate)","time":"\(last)"])
	}
	
	func calculateAverageCPU() -> JSON {
		var cpuLine = JSON([])
		let tempArray = self.cpuData
		if (tempArray.count > 0) {
			var totalApplicationUse: Float = 0
			var totalSystemUse: Float = 0
			var time: Int = 0
			for cpuItem in tempArray {
				totalApplicationUse += cpuItem.percentUsedByApplication
				totalSystemUse += cpuItem.percentUsedBySystem
				time = cpuItem.timeOfSample
			}
			cpuLine = JSON([
				"time":"\(time)",
				"process":"\(totalApplicationUse/Float(tempArray.count))",
				"system":"\(totalSystemUse/Float(tempArray.count))"])
		}
		return cpuLine
	}
	

    func storeHTTP(myhttp: HTTPData) {
	    let currentTime = NSDate().timeIntervalSince1970
	    let tempArray = self.httpDataStore
        for httpJson in tempArray {
            if(currentTime - (Double(httpJson["time"].stringValue)! / 1000) > 1800) {
                self.httpDataStore.removeFirst()
            } else {
                break
            }
        }
        self.httpData.append(myhttp);
	    let httpLine = JSON(["time":"\(myhttp.timeOfRequest)","url":"\(myhttp.url)","duration":"\(myhttp.duration)","requestMethod":"\(myhttp.requestMethod)","statusCode":"\(myhttp.statusCode)"])
	    self.httpDataStore.append(httpLine)
        let urlTuple = self.httpURLData[myhttp.url]
        if(urlTuple != nil) {
            let averageResponseTime = urlTuple!.0
            let hits = urlTuple!.1
            // Recalculate the average
            self.httpURLData.updateValue(((averageResponseTime * hits + myhttp.duration)/(hits + 1), hits + 1), forKey: myhttp.url)
        } else {
            self.httpURLData.updateValue((myhttp.duration, 1), forKey: myhttp.url)
        }
    }


    func storeCPU(cpu: CPUData) {
        let currentTime = NSDate().timeIntervalSince1970
        let tempArray = self.cpuDataStore
       	if tempArray.count > 0 {
       		for cpuJson in tempArray {
           		if(currentTime - (Double(cpuJson["time"].stringValue)! / 1000) > 1800) {
	                self.cpuDataStore.removeFirst()
           		} else {
                	break
	            }
        	}
       	}
       	self.cpuData.append(cpu);
    	let cpuLine = JSON(["time":"\(cpu.timeOfSample)","process":"\(cpu.percentUsedByApplication)","system":"\(cpu.percentUsedBySystem)"])
    	self.cpuDataStore.append(cpuLine)
    }

    func storeMem(mem: MemData) {
	    let currentTime = NSDate().timeIntervalSince1970
	    let tempArray = self.memDataStore
        if tempArray.count > 0 {
        	for memJson in tempArray {
            	if(currentTime - (Double(memJson["time"].stringValue)! / 1000) > 1800) {
	                self.memDataStore.removeFirst()
            	} else {
               		break
	        	}
	        }
	    }
   		let memLine = JSON([
	    	"time":"\(mem.timeOfSample)",
    		"process":"\(mem.applicationRAMUsed)",
	    	"system":"\(mem.totalRAMUsed)"
   		])
   		self.memDataStore.append(memLine)
    }

    public func getcpuRequest(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        response.headers["Content-Type"] = "application/json"
        let tempArray = self.cpuDataStore
        if tempArray.count > 0 {
            try response.status(.OK).send(json: JSON(tempArray)).end()	        
            self.cpuDataStore.removeAll()
        } else {
    		try response.status(.OK).send(json: JSON([])).end()	        
        }
    }
    
	public func getmemRequest(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
       	response.headers["Content-Type"] = "application/json"
        let tempArray = self.memDataStore
        if tempArray.count > 0 {
		    try response.status(.OK).send(json: JSON(tempArray)).end()	        
           	self.memDataStore.removeAll()
        } else {
   			try response.status(.OK).send(json: JSON([])).end()	        
        }
    }

    public func getenvRequest(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        response.headers["Content-Type"] = "application/json"
        var responseData: [JSON] = []
        for (param, value) in self.monitor.getEnvironmentData() {
            switch param {
                case "command.line":
                    let json: JSON = ["Parameter": "Command Line", "Value": value]
                    responseData.append(json)
                case "environment.HOSTNAME":
                    let json: JSON = ["Parameter": "Hostname", "Value": value]
                    responseData.append(json)
                case "os.arch":
                    let json: JSON = ["Parameter": "OS Architecture", "Value": value]
                    responseData.append(json)
                case "number.of.processors":
                    let json: JSON = ["Parameter": "Number of Processors", "Value": value]
                    responseData.append(json)
                default:
                    break
			}
        }
		try response.status(.OK).send(json: JSON(responseData)).end()	        
	}

	public func gethttpRate(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        response.headers["Content-Type"] = "application/json"
        try response.status(.OK).send(json: self.calculateHTTPRate()).end()	        
    }

	public func getcpuAverages(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        response.headers["Content-Type"] = "application/json"
		try response.status(.OK).send(json: self.calculateAverageCPU()).end()	        
    }

	public func gethttpRequest(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        response.headers["Content-Type"] = "application/json"
        let tempArray = self.httpDataStore
        if tempArray.count > 0 {
            try response.status(.OK).send(json: JSON(tempArray)).end()	        
          	self.httpDataStore.removeAll()
        } else {
			try response.status(.OK).send(json: JSON([])).end()	        
        }
    }

	public func gethttpAverages(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        response.headers["Content-Type"] = "application/json"
        var responseData:[JSON] = []
        let tempArray = self.httpURLData
        if tempArray.count > 0 {
            for (key, value) in tempArray {
                let json : JSON = ["url": key, "averageResponseTime": value.0]
                responseData.append(json)
            }
        }
        try response.status(.OK).send(json: JSON(responseData)).end()
    }
        
}
