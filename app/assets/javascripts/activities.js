// Datatables
$(document).ready( function () {
	$('#activities').dataTable( {
		"sDom": '<"H"Cfr>t<"F"ip>',
		"iDisplayLength": 50,
		"bJQueryUI": true,
		"aoColumns": [
		    { "bSortable": false },
		    null,
		    { "sType": "title-numeric" }
		],
		"aaSorting": [[ 2, "desc" ]]
	} );
} );