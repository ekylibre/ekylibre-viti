(function (E, $) {
  E.CviMap = class CviMap extends E.Map {
    constructor(el, options) {
      if (options == null) {
        options = {};
      }
      super(el, options);
      this.displayCadastralLandParcelZone =
        this.displayCadastralLandParcelZone.bind(this);
      this.el = el;
      this.initControls();
      this.asyncLayersLoading();
      this.configMap();
      this.displayCadastralLandParcelZone();
      this.firstLoad = true;
    }

    initControls() {
      this.removeControl('edit')
      const editLayer = this._cartography.getOverlay("edition");
      const layersControl = this._cartography.controls
        .get("layers")
        .getControl();
      layersControl.removeLayer(editLayer);
    }

    asyncLayersLoading() {
      const asyncLayers = this._cartography.options.layers.filter(
        (layer) => layer.asyncUrl != null
      );
      return (() => {
        const result = [];
        for (var asyncLayer of Array.from(asyncLayers)) {
          const onSuccess = (data) => {
            return this.onSync(data, asyncLayer.name);
          };
          result.push(this.asyncLoading(asyncLayer.asyncUrl, onSuccess));
        }
        return result;
      })();
    }

    onSync() {
      let args, callback;
      if (arguments[arguments.length - 1].constructor.name === "Function") {
        args = arguments[0];
        callback = arguments[arguments.length - 1];
      } else {
        args = arguments;
      }

      const layerName = args[1];

      const onEachFeature = E[`${layerName}_onEachFeature`];

      [].push.call(args, { onEachFeature });

      this._cartography.sync.apply(this, args);

      if (callback) {
        callback.call(this, args);
      }
      $(document).trigger(E.Events.Map.ready);
      $(this.el).trigger(E.Events.Map.ready);
    }

    //TODO: move to cartography
    configMap() {
      this.ghostLabelCluster = L.ghostLabelCluster({
        type: "number",
        innerClassName: "leaflet-ghost-label-collapsed",
        margin: -3,
      });
      this.ghostLabelCluster.addTo(this._cartography.getMap());
      const ghostIconPane = this._cartography.getMap().createPane("ghost-icon");
      ghostIconPane.style.zIndex = 600;
      const makerPane = this._cartography.getMap().getPane("markerPane");
      makerPane.style.zIndex = 1000;
    }

    displayCadastralLandParcelZone(visible) {
      if (visible == null) {
        visible = true;
      }
      if (this._cadastralLandParcelZoneLoading) {
        return;
      }

      this._cartography.map.on("moveend", this.displayCadastralLandParcelZone);

      if (
        this.getZoom() < 17 &&
        this._cartography.getOverlay("cadastral_land_parcel_zones")
      ) {
        const cadastralZonesLayer = E.map._cartography.getFeatureGroup({
          name: "cadastral_land_parcel_zones",
        });
        for (let layer of Array.from(cadastralZonesLayer.getLayers())) {
          layer.selected = false;
        }
        this._cartography.removeOverlay("cadastral_land_parcel_zones");
      }

      if (this.getZoom() >= 17) {
        const selectedIds = $(".map").data("selected-ids") || [];
        const selectedIdsParams =
          selectedIds && selectedIds.length > 0
            ? `&selected_ids=${selectedIds}`
            : "";
        const url =
          "/backend/registered_cadastral_parcels" +
          `?bounding_box=${this.boundingBox()}` +
          selectedIdsParams;

        const onSuccess = (data) => {
          const onEachFeature = (feature, layer) => {
            const insertionMarker = function () {
              const { cadastral_ref } = layer.feature.properties;
              layer._ghostIcon = new L.GhostIcon({
                html: cadastral_ref,
                className: "simple-label white",
                iconSize: [40, 40],
              });
              layer._ghostMarker = L.marker(layer.getCenter(), {
                icon: layer._ghostIcon,
                pane: "ghost-icon",
              });

              layer._ghostMarker.addTo(layer._map);
              layer.addTo(layer._map);
              return layer.bringToBack();
            };

            layer.on("add", (e) => insertionMarker());

            return layer.on("remove", function (e) {
              if (layer._ghostMarker) {
                return layer._map.removeLayer(layer._ghostMarker);
              }
            });
          };

          const style = (feature) => ({
            color: "#ffffff",
            fillOpacity: 0,
            opacity: 1,
            dashArray: "6, 6",
            weight: 1,
          });

          const cadastralZonesSerie = [
            { cadastral_land_parcel_zones: data },
            [
              {
                name: "cadastral_land_parcel_zones",
                label: I18n.t("front-end.labels.cadastral_land_parcel_zones"),
                type: "simple",
                index: true,
                serie: "cadastral_land_parcel_zones",
                onEachFeature,
                style,
              },
            ],
          ];

          if (this.getZoom() >= 17) {
            this._cartography.addOverlay(cadastralZonesSerie);
          }
        };

        this.asyncLoading(url, onSuccess, "cadastralLandParcelZone");
      }
    }
  };

  $.loadCartographyMap = function () {
    if (!$("*[data-cvi-cartography]").length) {
      return;
    }
    const $el = $("*[data-cvi-cartography]").first();
    const opts = $el.data("cvi-cartography");
    E.map = new E.CviMap($el[0], opts);
  };

  $.reloadCartographyMap = function (keepBounds) {
    let currentBounds;
    if (keepBounds == null) {
      keepBounds = true;
    }
    const { map } = E;
    if (keepBounds) {
      currentBounds = map.getBounds();
    }
    $(map.el.children).remove();
    $.loadCartographyMap();
    if (keepBounds) {
      E.map.fitBounds(currentBounds);
    }
  };

  $(document).ready($.loadCartographyMap);

  $(document).on(E.Events.Map.ready, "*[data-cvi-cartography]", (e) =>
    $(e.target).css("visibility", "visible")
  );

  $(document).on(E.Events.Map.ready, function () {
    if (E.map.firstLoad) {
      E.map._cartography.setView();
    }
  });
})(ekylibre, jQuery);
