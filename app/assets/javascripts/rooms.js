$(document).ready( function () {
	register_all_rooms();
} );

function register_all_rooms() {
	register_datatable_rooms();
	register_delete_buttons_rooms();
}

function register_datatable_rooms() {
	$('#rooms').dataTable( {
		"sPaginationType": "full_numbers",
		"sDom": '<"H"Cfr>t<"F"ip>',
		"bJQueryUI": true,
		"aoColumns": [
			null,
		    null,
		    null,
		    { "bSortable": false, "bSearchable": false }
		]
	} );
}

function register_delete_buttons_rooms() {
	$('#rooms a.remote-delete').click(function() {
		if (confirm("Êtes vous sûr de vouloir supprimer cette chambre ?")) {
	    	$.post(this.href, { _method: 'delete' }, null , "json").always(
	  	  			function(data) { reload_rooms(); }
	  		  	);
	    };
  	  return false;
  	});
}

function reload_rooms() {
	$('#wrapper').load('/rooms/reload', function () {register_all_rooms();});
}
