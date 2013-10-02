$(document).ready( function () {
	$('#computer-dns').dataTable( {
		"sPaginationType": "full_numbers",
		"iDisplayLength": 50,
		"sDom": '<"H"Cfr>t<"F"ip>',
		"bJQueryUI": true,
		"aoColumns": [
			null,
		    null,
		    null,
		    { "bSortable": false, "bSearchable": false }
		]
	} );
} );