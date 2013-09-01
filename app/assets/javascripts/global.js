$(function () {
// Activation des tooltips de bootstrap
    $("[rel='tooltip']").tooltip();
});


//Traduction de DataTable
$.extend($.fn.dataTable.defaults.oLanguage, {
    "sProcessing":     "Traitement en cours...",
    "sSearch":         "Rechercher&nbsp;:",
    "sLengthMenu":     "Afficher _MENU_ &eacute;l&eacute;ments",
    "sInfo":           "Affichage des &eacute;lements _START_ &agrave; _END_ sur _TOTAL_ &eacute;l&eacute;ments",
    "sInfoEmpty":      "Affichage de l'&eacute;lement 0 &agrave; 0 sur 0 &eacute;l&eacute;ments",
    "sInfoFiltered":   "(filtr&eacute; de _MAX_ &eacute;l&eacute;ments au total)",
    "sInfoPostFix":    "",
    "sLoadingRecords": "Chargement en cours...",
    "sZeroRecords":    "Aucun &eacute;l&eacute;ment &agrave; afficher",
    "sEmptyTable":     "Aucune donnée disponible dans le tableau",
    "oPaginate": {
        "sFirst":      "Début",
        "sPrevious":   "Pr&eacute;c&eacute;dent",
        "sNext":       "Suivant",
        "sLast":       "Fin"
    },
    "oAria": {
        "sSortAscending":  ": activer pour trier la colonne par ordre croissant",
        "sSortDescending": ": activer pour trier la colonne par ordre décroissant"
    }
});

//Fermeture du modal lors de l'appui sur la touche échap
$(document).bind("keyup", null, function(e) { 
    if (e.keyCode == 27) {
        $('#modal-window').modal('hide');
    } 
});

//Pour le tri par date des DataTables
jQuery.extend( jQuery.fn.dataTableExt.oSort, {
    "title-numeric-pre": function ( a ) {
        var x = a.match(/title="*(-?[0-9\.]+)/)[1];
        return parseFloat( x );
    },
 
    "title-numeric-asc": function ( a, b ) {
        return ((a < b) ? -1 : ((a > b) ? 1 : 0));
    },
 
    "title-numeric-desc": function ( a, b ) {
        return ((a < b) ? 1 : ((a > b) ? -1 : 0));
    }
} );