// Datatables
$(document).ready( function () {
	$('#adherents').dataTable( {
		"sPaginationType": "full_numbers",
		"sDom": '<"H"Cfr>t<"F"ip>',
		"bJQueryUI": true,
		"aoColumns": [
			null,
		    null,
		    null,
		    null,
		    { "bSortable": false, "bSearchable": false }
		]
	});
} );
<<<<<<< HEAD

// Selects in form
$('select').select2();
=======
>>>>>>> 6d299dfb9b0a4c3197311b60d44d613cd23cfd8f
