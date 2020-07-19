%dw 2.0
output application/json skipNullOn="everywhere"
---
{
	code: "ERROR",
	(description : vars.responseDescription as String) 
	  if vars.responseDescription?,
	correlationId: vars.logprefix,
	additionalDetails: vars.additionalDetails
}