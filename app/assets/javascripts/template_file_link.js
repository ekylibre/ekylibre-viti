(function($) {
  $(document).ready(function(event) {
    if ($("select#import_nature").length === 0) {
      return;
    }
    $("select#import_nature").change(function() {
      var selectedImport = $(this)
        .children("option:selected")
        .val();
      if (selectedImport === "ekylibre_cvi_csv") {
        const link =
          '<a href="/backend/imports/template_file" download>Télécharger un modèle de CVI</a>';
        $("#general-informations div.fieldset-fields").append(link);
      } else {
        debugger;
        const link_element = $(".fieldset-fields > a");
        link_element.length > 0 && link_element.remove();
      }
    });
  });
})(jQuery);
