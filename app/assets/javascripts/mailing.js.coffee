$(document).ready ->
  $("#mailings").dataTable
    sPaginationType: "full_numbers"
    sDom: "<\"H\"Cfr>t<\"F\"ip>"
    bJQueryUI: true
    aoColumns: [null, null, null,
      bSortable: false
    ]

$ ()->
  $("form.new_mailing").on "ajax:success", (event, data, status, xhr) ->
    $('#new-mailing-modal').modal('hide')