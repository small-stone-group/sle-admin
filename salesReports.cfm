<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Stock Sales &amp; Purchase</title>
<link rel="stylesheet" type="text/css" href="css/main3.css"/>
<style>
	.sale {color:#FF00FF; line-height:16px;}
	.purch {color:#0000FF; line-height:16px;}
	.group {font-size:24px; font-weight:bold}
</style>
</head>

<cfsetting requesttimeout="900">
<cfparam name="theYear" default="#Year(now())#">
<cfparam name="group" default="31">
<cfparam name="category" default="0">
<cfobject component="code/sales" name="sales">
<cfset parms={}>
<cfset parms.datasource=application.site.datasource1>
<cfset parms.grpID=group>
<cfset parms.catID=category>
<cfset parms.rptYear=theYear>
<cfset QSales = sales.stockSalesByMonth(parms)>
<!---<cfdump var="#QSales#" label="QSales" expand="false">--->
<cfset Purch = sales.stockPurchByMonth(parms)>
<cfset groups = sales.LoadGroups(parms)>
<!---<cfdump var="#Purch#" label="Purch" expand="false">--->
<body>
<cfoutput>
	<div>
		<form method="post" enctype="multipart/form-data">
			Report Date:
			<select name="group" id="group">
				<option value="">Select group...</option>
				<cfloop query="groups.ProductGroups">
				<option value="#pgID#" <cfif parms.grpID eq pgID> selected</cfif>>#pgTitle#</option>
				</cfloop>
			</select>
			<input type="submit" name="btnGo" value="Go">
		</form>
	</div>
	<table class="tableList" border="1">
		<tr>
			<th>Stock Report</th>
			<th>Size</th>
			<th width="30" align="right">Jan</th>
			<th width="30" align="right">Feb</th>
			<th width="30" align="right">Mar</th>
			<th width="30" align="right">Apr</th>
			<th width="30" align="right">May</th>
			<th width="30" align="right">Jun</th>
			<th width="30" align="right">Jul</th>
			<th width="30" align="right">Aug</th>
			<th width="30" align="right">Sep</th>
			<th width="30" align="right">Oct</th>
			<th width="30" align="right">Nov</th>
			<th width="30" align="right">Dec</th>
			<th width="50" align="right">Total</th>
			<th width="50" align="right">Stock</th>
		</tr>
	<cfset categoryID = 0>
	<cfset groupID = 0>
	<cfloop query="QSales.salesItems">
		<cfif groupID neq pgID>
			<tr>
				<th colspan="16"><span class="group">#pgTitle#</span></th>
			</tr>
			<cfset groupID = pgID>
		</cfif>
		<cfif categoryID neq pcatID>
			<tr>
				<th colspan="16">#pcatTitle#</th>
			</tr>
			<cfset categoryID = pcatID>
		</cfif>

		<cfset purRec = {}>
		<cfif StructKeyExists(Purch.stock,prodID)>
			<cfset purRec = StructFind(Purch.stock,prodID)>
		</cfif>
		<tr>
			<td><a href="productStock6.cfm?product=#prodID#" target="stockcheck">#prodTitle#</a>
			&pound;<cfif !StructIsEmpty(purRec)>#purRec.siOurPrice#<cfelse>&nbsp;</cfif></td>
			<td><cfif !StructIsEmpty(purRec)>#purRec.siUnitSize#<cfelse>&nbsp;</cfif></td>
			<cfloop list="jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec" index="mnth">
				<cfset mnthSale = QSales.salesItems[mnth][currentrow]>
				<cfset mnthPurch = 0>
				<cfif !StructIsEmpty(purRec)><cfset mnthPurch = StructFind(purRec,mnth)></cfif>
				<td width="30" align="right">
					<span class="sale"><cfif mnthSale gt 0>#mnthSale#<cfelse>&nbsp;</cfif><br /></span>
					<span class="purch"><cfif mnthPurch gt 0>#mnthPurch#<cfelse>&nbsp;</cfif></span>
				</td>
			</cfloop>
			<td width="50" align="right">
				<span class="sale">#total#<br /></span>
				<span class="purch"><cfif !StructIsEmpty(purRec)>#purRec.total#<cfelse>&nbsp;</cfif></span>
			</td>
			<td width="50" align="right">
				<cfif !StructIsEmpty(purRec)>#purRec.total - total#</cfif>
			</td>
		</tr>
	</cfloop>
	</table>
</cfoutput>
</body>
</html>
