$(document).ready( function () {
	register_all_adherents();
} );

function register_all_adherents() {
	register_datatable_adherents();
	register_delete_buttons_adherents();
}

function register_datatable_adherents() {
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
}

function register_delete_buttons_adherents() {
	$('#adherents a.remote-delete').click(function() {
		if (confirm("Êtes vous sûr de vouloir supprimer cet adhérent ?")) {
	    	$.post(this.href, { _method: 'delete' }, null , "json").always(
	  	  			function(data) { reload_adherents(); }
	  		  	);
	    }
  	  return false;
  	});
}

function reload_adherents() {
	$('#wrapper').load('adherents/reload', function () {register_all_adherents();});
}
