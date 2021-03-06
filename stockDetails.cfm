<!DOCTYPE html>
<html>
<head>
<title>Stock Order Details</title>
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<link href="css/main3.css" rel="stylesheet" type="text/css">
<link href="css/main4.css" rel="stylesheet" type="text/css">
<link href="css/productstock.css" rel="stylesheet" type="text/css">
<link href="css/labels-small.css" rel="stylesheet" type="text/css">
<link href="css/chosen.css" rel="stylesheet" type="text/css">
<link href="css/jquery-ui-1.10.3.custom.min.css" rel="stylesheet" type="text/css">
<script src="common/scripts/common.js"></script>
<script src="scripts/jquery-1.9.1.js"></script>
<script src="scripts/jquery-ui.js"></script>
<script src="scripts/jquery.dcmegamenu.1.3.3.js"></script>
<script src="scripts/jquery.hoverIntent.minified.js"></script>
<script src="scripts/chosen.jquery.js" type="text/javascript"></script>
<script src="scripts/autoCenter.js" type="text/javascript"></script>
<script src="scripts/main.js" type="text/javascript"></script>
<script src="scripts/popup.js" type="text/javascript"></script>
<script src="scripts/jquery.PrintArea.js" type="text/javascript"></script>
<script src="scripts/jquery-barcode.js" type="text/javascript"></script>
<script src="scripts/productStock.js" type="text/javascript"></script>
<script type="text/javascript">
	$(document).ready(function() { 
		$('#menu').dcMegaMenu({rowItems: '3',event: 'hover',fullWidth: true});
		$('#btnPrintLabels').click(function(e) {
			$('#order-list').addClass("noPrint");
			$('#wrapper').addClass("noPrint");
			$('#print-area').removeClass("noPrint");
			PrintLabels("#listForm","#LoadPrint");
			e.preventDefault();
		});
		$('#btnPrintList').click(function(e) {
			$('#order-list').removeClass("noPrint");
			$('#wrapper').removeClass("noPrint");
			$('#print-area').addClass("noPrint");
			window.print();
			e.preventDefault();
		});
		$('#selectAll').click(function(e) {   
			if(this.checked) {
				$('.selectitem').prop({checked: true});
			} else {
				$('.selectitem').prop({checked: false});
			};
		});
		var isEditingTitle = false;
		$('.sod_title').click(function(event) {
			if (!isEditingTitle) {
				var value = $(this).html();
				var prodID = $(this).attr("data-id");
				var htmlStr = "<input type='text' value='" + value + "' class='sod_title_input' data-id='" + prodID + "'>";
				$(this).html(htmlStr);
				$(this).find('.sod_title_input').focus();
			}
			isEditingTitle = true;
		});
		$(document).on("blur", ".sod_title_input", function(event) {
			var value = $(this).val();
			var prodID = $(this).attr("data-id");
			var cell = $(this).parent('.sod_title');
			$.ajax({
				type: "POST",
				url: "saveProductTitle.cfm",
				data: {"title": value, "prodID": prodID},
				success: function(data) {
					cell.html(data.trim());
					isEditingTitle = false;
				}
			});
		});
	});
</script>
<style type="text/css">
	.priceDiff {background-color:#FADCD8;}
	.priceMatch {background-color:#fff;}
	.rowGrey {color:#CCC;}
	.header {font-size:14px; font-weight:bold;}
	.headleft {text-align:left; font-size:12px;}
	.headright {text-align:right; font-size:12px;}
	.substitute {color:#FF0000; font-weight:bold;}
	@page {size:portrait;margin:40px;}

	@media print {
		.noPrint {display:none;}
	}
</style>
</head>

<cftry>
<cfparam name="ref" default="">
<cfobject component="code/stock" name="stock">
<cfif len(ref)>
	<cfset parm={}>
	<cfset parm.datasource=application.site.datasource1>
	<cfset parm.ref=ref>
	<cfset stockSheet=stock.OrderDetails(parm)>
</cfif>
<body>
	<div id="wrapper">
		<div class="noPrint"><cfinclude template="sleHeader.cfm"></div>
		<div id="content">
			<div id="content-inner">
				<div id="orderOverlay-ui"></div>
				<div id="orderOverlay">
					<div id="orderOverlayForm">
						<a href="##" class="orderOverlayClose">X</a>
						<div id="orderOverlayForm-inner"></div>
					</div>
				</div>
				<div id="order-list" style="page-break-inside:avoid;">
					<cfoutput>
						<script>
							$(document).ready(function(e) {
								$('##btnSaveLabels').click(function(event) {
									var list = [];
									$('.selectitem').each(function(i, e) {
										if ($(e).prop("checked")) {
											list.push($(e).val());
										}
									});
									$.ajax({
										type: "POST",
										url: "stockSaveList.cfm",
										data: {
											"list": JSON.stringify(list),
											"type": "append"
										},
										success: function(data) {
											$.messageBox("List Updated", "success");
										}
									});
									event.preventDefault();
								});
							});
						</script>
						<div id="bcTarget"></div>
						<div class="module">
						<div style="background:##D9FFCA; float:left; text-align:center; padding:10px; font-weight:bold; font-size:14px; margin:0 5px 5px 0; border:1px solid ##000;">
							New Products
						</div>
						<div style="background:##FADCD8; float:left; text-align:center; padding:10px; font-weight:bold; font-size:14px; margin:0 5px 5px 0; border:1px solid ##000;">
							Retail Price Different To Our Price
						</div>
						<form method="post" id="listForm">
							<div id="order-controls" class="noPrint">
								<input type="button" id="btnSaveLabels" value="Save Labels To List" />
								<input type="button" id="btnPrintLabels" value="Print Labels" />
								<input type="button" id="btnPrintList" value="Print List" />
							</div>
							</div>
							<div class="module">
							<div class="clear"></div>
							<cfif stockSheet.count gt 0>
								<table width="100%" class="tableList" border="1">
									<tr>
										<td class="header" colspan="4">Reference: #stockSheet.OrderRef# (ID: #stockSheet.orderID#)</td>
										<td class="header" colspan="6">Order Date: #stockSheet.OrderDate#</td>
										<td colspan="3"></td>
									</tr>
									<tr>
										<th class="headleft noPrint"><input type="checkbox" id="selectAll" value="1" checked="checked" style="width:20px; height:20px;" /></th>
										<th class="headleft">##</th>
										<th class="headleft">Barcode</th>
										<th class="headleft">Reference</th>
										<th class="headleft">Description</th>
										<th class="headleft">Unit Size</th>
										<th class="headright">WSP</th>
										<th>Packs</th>
										<th class="headright" width="40">Our Price</th>
										<th>PM</th>
										<th class="headright">POR</th>
										<th width="40">VAT Rate</th>
										<th width="40">Status</th>
									</tr>
									<cfset rowCount=0>
									<cfset itemCount=0>
									<cfset category="">
									<cfset orderTotal=0>
									<cfset recvdTotal=0>
									<cfset avgPOR = 0>
									<cfloop array="#stockSheet.items#" index="item">
										<cfset avgPOR += item.prodPOR>
										<cfif StructKeyExists(item,"prodRef") AND item.prodref neq "not found">
											<cfset rowCount++>
											<cfset itemCount++>
											<cfif StructKeyExists(item,"prodPackPrice") AND StructKeyExists(item,"siQtyPacks")>
												<cfset orderTotal=orderTotal+(val(item.prodPackPrice)*val(item.siQtyPacks))>
												<cfset recvdTotal=recvdTotal+(val(item.prodPackPrice)*val(item.siReceived))>
											</cfif>
											<cfif rowCount is 24>
												<cfset rowCount=0>
												</table>
												<div style="page-break-after:always;"></div>
												<table width="100%" class="tableList" border="1">
													<tr>
														<th class="noPrint"></th>
														<th class="headleft">##</th>
														<th class="headleft">Barcode</th>
														<th class="headleft">Reference</th>
														<th class="headleft">Description</th>
														<th class="headleft">Unit Size</th>
														<th class="headright">WSP</th>
														<th>Packs</th>
														<th class="headright" width="50">Our Price</th>
														<th>PM</th>
														<th class="headright">POR</th>
														<th width="40">VAT Rate</th>
														<th width="40">Status</th>
													</tr>
											</cfif>
											<cfif item.category neq category>
												<tr>
													<td></td>
													<td colspan="13" style="background-color:##EFF3F7"><strong>#item.category#</strong></td>
												</tr>
												<cfset category=item.category>
											</cfif>
											<cfif item.prodRRP NEQ item.prodOurPrice>
												<cfset rowColor="priceDiff">
											<cfelse><cfset rowColor="priceMatch"></cfif>
											<cfif item.siSubs GT 0>
												<cfset rowColor="#rowColor# rowGrey">
											</cfif>
											<tr class="#rowColor#" <cfif item.newFlag>style="background-color:##D9FFCA;"</cfif>>
												<td class="noPrint"><input type="checkbox" name="selectitem" class="selectitem" value="#item.prodID#" <cfif item.changedFlag OR item.newFlag>checked="checked"</cfif> /></td>
												<td>#itemCount#</td>
												<td width="100">
												<script type="text/javascript">
													$(document).ready(function() {
														var code="#Right(item.barCode,13)#";
														var type="ean13";
														if (code.length == 8) {
															type="ean8";
														} else if (code.length == 13) {
															type="ean13";
														} else {
															type="upc";
														}
														$(".barcode#itemCount#").barcode(code, type); //,{barWidth:2, barHeight:20}
													});
												</script>
												<div class="barcode#itemCount#">#item.barCode#</div>
												</td>
												<td><a href="ProductStock6.cfm?product=#item.prodID#" target="_blank">#item.prodRef#</a>
													<cfif len(item.msg)><br /><span class="substitute">#item.msg#</span></cfif></td>
												<td class="sod_title" data-id="#item.prodID#">#item.prodTitle#</td>
												<td>#item.prodPackQty# X #item.prodUnitSize#</td>
												<td align="right">#item.prodPackPrice# <br>(#item.prodUnitTrade#)</td>
												<td align="center">#item.siQtyPacks#</td>
												<td align="right"><strong>#item.prodOurPrice#</strong></td>
												<td align="center">#YesNoFormat(item.prodPriceMarked)#</td>
												<td align="right">#item.prodPOR#%</td>
												<td align="right">#DecimalFormat(item.prodVATRate)#%</td>
												<td align="right">#item.siStatus#</td>
											</tr>
										</cfif>
									</cfloop>
									<cfset avgPOR = avgPOR / itemCount>
									<tr height="30">
										<td class="noPrint"></td>
										<td class="headright" colspan="6">Average POR #DecimalFormat(avgPOR)#% &nbsp; Order Value</td>
										<td class="headright">#DecimalFormat(orderTotal)#</td>
										<td class="headright" colspan="3">Received Value</td>
										<td class="headright">#DecimalFormat(recvdTotal)#</td>
										<td></td>
									</tr>
								</table>
							<cfelse>
								No items found for order #ref#.
							</cfif>
						</form>
						</div>
					</cfoutput>
				</div>
			</div>
		</div>
		<!---<div class="noPrint"><cfinclude template="sleFooter.cfm"></div>--->
	</div>
	<cfif application.site.showdumps>
		<cfdump var="#session#" label="session" expand="no">
		<cfdump var="#application#" label="application" expand="no">
		<cfdump var="#variables#" label="variables" expand="no">
	</cfif>
	<div id="print-area"><div id="LoadPrint"></div></div>

    <cfcatch type="any">
		<cfdump var="#cfcatch#" label="cfcatch" expand="yes" format="html" 
		output="#application.site.dir_logs#err-#DateFormat(Now(),'yyyymmdd')#-#TimeFormat(Now(),'HHMMSS')#.htm">
    </cfcatch>
	</body>
</cftry>
</html>
