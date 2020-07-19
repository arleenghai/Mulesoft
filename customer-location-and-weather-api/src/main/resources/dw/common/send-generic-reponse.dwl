%dw 2.0
output application/json skipNullOn="everywhere"
---
{
	code : "INFO",
	description : if (vars.responseDescription?) 
	vars.responseDescription 
	else 
	"Requested operation was successfully processed",
	correlationId: vars.logprefix,
	additionalDetails: vars.additionalDetails
}