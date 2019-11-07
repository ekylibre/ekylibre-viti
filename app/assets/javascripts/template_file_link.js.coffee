(($) ->
  $(document).ready (event) ->
    $('select#import_nature').change ->
      selectedImport = $(this).children('option:selected').val()
      if selectedImport != 'ekylibre_cvi_csv'
        $('#cvi_file_template_link').hide()
      if selectedImport == 'ekylibre_cvi_csv'
        $('#cvi_file_template_link').toggle()
) jQuery
