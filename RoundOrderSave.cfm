<!--- AJAX call - check client do not show debug data at all --->
<cfset callback=1><!--- force exit of onrequestend.cfm --->
<cfsetting showdebugoutput="no" requesttimeout="300">
<cfparam name="print" default="false">

<cfobject component="code/rounds" name="rnd">
<cfset parm={}>
<cfset parm.datasource=application.site.datasource1>
<cfset parm.form=form>
<cfset order=rnd.SaveRoundOrder(parm)>

<cfoutput>
	<cfif StructKeyExists(order,"msg")>#order.msg#</cfif>
</cfoutput>

