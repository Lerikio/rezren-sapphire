// Datatables
$(document).ready( function () {
	$('#payments').dataTable( {
		"sPaginationType": "full_numbers",
		"sDom": '<"H"Cfr>t<"F"ip>',
		"bJQueryUI": true,
		"aoColumns": [
			null,
		    null,
		    null,
<<<<<<< HEAD
		    { "bSortable": false }
=======
		    { "bSortable": false, "bSearchable": false }
>>>>>>> 6d299dfb9b0a4c3197311b60d44d613cd23cfd8f
		]
	} );
} );