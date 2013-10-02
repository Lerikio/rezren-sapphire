$(document).ready( function () {
	register_all_mailings();
} );

function register_all_mailings() {
	register_datatable_mailings();
	register_delete_buttons_mailings();
}

function register_datatable_mailings() {
	$('#mailings').dataTable( {
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

function register_delete_buttons_mailings() {
	$('#mailings a.remote-delete').click(function() {
		if (confirm("Êtes vous sûr de vouloir supprimer cette mailing ?")) {
	    	$.post(this.href, { _method: 'delete' }, null , "json").always(
	  	  			function(data) { reload_mailings(); }
	  		  	);
	    }
  	  return false;
  	});
}

function reload_mailings() {
	$('#wrapper').load('mailings/reload', function () {register_all_mailings();});
}
