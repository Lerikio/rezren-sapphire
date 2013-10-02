$(document).ready( function () {
	register_all_computers();
} );

function register_all_computers() {
	register_datatable_computers();
	register_delete_buttons_computers();
}

function register_datatable_computers() {
	$('#computers').dataTable( {
		"sPaginationType": "full_numbers",
		"iDisplayLength": 50,
		"sDom": '<"H"Cfr>t<"F"ip>',
		"bJQueryUI": true,	
		"aoColumns": [
			null,
			null,
		    null,
		    null,
		    { "bSortable": false, "bSearchable": false }
		]
	} );
}

function register_delete_buttons_computers() {
	$('#computers a.remote-delete').click(function() {
		if (confirm("Êtes vous sûr de vouloir supprimer cette mailing ?")) {
	    	$.post(this.href, { _method: 'delete' }, null , "json").always(
	  	  			function(data) { reload_computers(); }
	  		  	);
	    }
  	  return false;
  	});
}

function reload_computers() {
	$('#wrapper').load('computers/reload', function () {register_all_computers();});
}
