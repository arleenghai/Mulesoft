# Mulesoft
This project includes 3 files-

1)RAML Api Specification
2)customer-location-and-weather-api-1.0.0-SNAPSHOT-nule-application(1).jar - JAR file to import the project in the Anypoint Studio
3)customer-location-and-weather-api - project with source code

#Customer Location and Weather Information API

Requirements:
Create a customer information api with current weather data in customer's location

Assumptions:
1) This document assumes that you are familiar with Mule and the Anypoint™ Studio interface. Further, this example assumes that you have a basic understanding of Mule flows, Mule Global Elements, and Anypoint DataWeave.

This document describes the details of the example within the context of Anypoint Studio, Mule ESB’s graphical user interface.

2) Assuming Customer city- Melbourne and Customer country- Australia (AU)

Usage:
1) Import the JAR file in anypoint studio to run the project
- refer customer-location-and-weather-api-1.0.0-SNAPSHOT-nule-application(1).jar file attached
OR
copy the customer-location-and-weather-api project in Anypoint studio Workspace
2) Import the RAML API specification in the design Center to access the Mock 
- refer Mulesoft->RAML Api Specification->customer-location-and-weather-api-1.0.2-raml(1)

Best Practices used:
1) Maintained customerlocationtypes API fragment containing the Types used in the API Specification for scalability and reuseability as these API fragments can be referred in different APIs
- refer RAML Api Specification->customer-location-and-weather-api-1.0.2-raml(1)->exchange_modules/d23ae04c-4b09-4fbb-86d2-8363672331ab->customerlocationtypes.raml

2) Used Shared Resources to be used accross the customer-location-and-weather-api project domain. Shared resources are maintained under the Common folder in the project.
- refer customer-location-and-weather-api->src->main->mule->common->global-config.xml
- refer customer-location-and-weather-api->src->main->mule->common->shared-flows.xml

3) Implemented error handling.
 a) generic-apikit-error-handler.xml
 b) common-error-handler.xml - for Mule flows
 - refer customer-location-and-weather-api->src->main->mule->error-handling

4) Used Basic Authentication for security, which can be maintained under the Properties folder in the src->main->resources->properties file and encrypted by Secure Properties Tool using AES algortihm and CBC mode and Mule Key.

5) Used Validate size element for checking if the http request to current weather data is successful.

6) Implemented logging for application and error logs using Logger which can be seen under Runtime Manager-> Application-> Logs

Implementation:
1) Create a project in the Anipoint studio by importing customer-location-and-weather-api RAML API Specification
2) The project is divided into 3 parts-
customer-location-and-weather-api-main
customer-location-and-weather-api-console
customer-location-and-weather-api-config
3) Configure the HTTP-Listener-config with the host and port 
4) Create 2 error handlers for Apikit error handling and mule flow error handling
5) create flow for POST method for getting the current weather data for Melbourne, Australia for customer John Smith based on the Input Request

a) Log the commencement of weather information details using Logger
<logger level="INFO" doc:name="Start" doc:id="cb559651-a85d-4b2d-9a10-141bf1cf3485" message="Commencement of Weather information details"/>

b) Save the initial request in transform message-
				<ee:set-variable variableName="customerInformation" ><![CDATA[%dw 2.0
output application/json
---
{
	name: payload.name,
	lastName: payload.lastName,
	dateTime: payload.dateTime,
	city: payload.city,
	country: payload.country
}]]></ee:set-variable>

b) save city and country in a variable to pass as queryParameter to the http request to get the current weather data for melbourne
<ee:set-variable variableName="cityandcountry" ><![CDATA[payload.city ++ "," ++ payload.country]]></ee:set-variable>
			</ee:variables>

c) create a HTTP-REQUEST-CONFIGURATION (GET method) in the global-config.xml for getting current weather data for Melbourne,au
Note: Again, HTTP-REQUEST-CONFIGURATION can be maintained in the properties folder and encrypted using secure properties tool for security. I haven't done it for now as this is a dummy project and have hardcoded the values for now.

<http:request-config name="Weather-Data-HTTP_Request_configuration" doc:name="HTTP Request configuration" doc:id="2558699a-dd20-427f-9a59-76fd2bdc589a" >
		<http:request-connection protocol="HTTPS" port="443" host="api.openweathermap.org"/>
	</http:request-config>

<http:request method="GET" doc:name="get current weather data for given city" doc:id="92d70b0c-8335-4ab2-81ed-324fc9b89bfd" config-ref="Weather-Data-HTTP_Request_configuration" path="data/2.5/weather">
			<http:query-params ><![CDATA[#[output application/java
---
{
	q : vars.cityandcountry,
	appid : "d6766ea74b0d1a0e007025a47ed6afa2"
}]]]></http:query-params>
		</http:request>

d) Validate if the http request to open weather map was successful by using Validate Size element from the mule palette
<validation:validate-size doc:name="Check if current weather data is retrieved" doc:id="3892ed9c-e9db-40ad-9cad-655beaaffb47" value="#[payload]" min="1" message="Current weather data retrieval failure">
			<error-mapping sourceType="VALIDATION:INVALID_SIZE" targetType="WEATHER_DATA:INTERNAL_SERVER_FAILURE" />
		</validation:validate-size>

e) Transform the response from the open weather map to the output message using dataweave
- convert timmeZone from Number to String
- for fullName, concatenate the name and lastName from the input request
- dateTime, ISO 8601 for location + 1day is obtained by dateTime: now() + |P1D|

<ee:transform doc:name="transforming weather data intoFinal Output" doc:id="9858a742-c0bd-454e-b0f4-e391d8841360" >
			<ee:message >
				<ee:set-payload ><![CDATA[%dw 2.0
output application/json
---
{
	lastName: vars.customerInformation.lastName,
	name: vars.customerInformation.name,
	timmeZone: payload.timezone as String,
	offfset: null,
	fullName: vars.customerInformation.name ++ " " ++ vars.customerInformation.lastName,
	temperatureCelcius: payload.main.temp,
	dateTime: now() + |P1D|,
	city: payload.name,
	location: payload.sys.country
}]]></ee:set-payload>
			</ee:message>
		</ee:transform>


