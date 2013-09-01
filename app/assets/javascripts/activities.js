// Datatables
$(document).ready( function () {
	$('#activities').dataTable( {
		"sDom": '<"H"Cfr>t<"F"ip>',
		"bJQueryUI": true,
		"aoColumns": [
		    { "bSortable": false },
		    null,
		    { "sType": "title-numeric" }
		],
		"aaSorting": [[ 2, "desc" ]]
	} );
} );