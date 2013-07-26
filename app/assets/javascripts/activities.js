$(document).ready( function () {
	$('#activities').dataTable( {
		"sDom": '<"H"Cfr>t<"F"ip>',
		"bJQueryUI": true,
		"aoColumns": [
		    { "bSortable": false },
		    null,
		    null
		]
	} );
} );