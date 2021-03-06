import QtQuick 2.7
import QtQuick.Controls 2.1

import ArcGIS.AppFramework 1.0
import Esri.ArcGISRuntime 100.5

import "../controls" as Controls

Page {
    id: pageItem

    property bool regionInitLoad: true

    property alias saveState: saveStagePg
    property alias offlinePg: offlinePg
    property Point currentPositionPoint: Point {x: 90.943869; y: 24.890659; spatialReference: SpatialReference.createWgs84()}

    property real scaleFactor: AppFramework.displayScaleFactor
    property url wms3dayServiceUrl: "http://floodobservatory.colorado.edu/geoserver/AS_3day_rs/wms?service=wms&request=getCapabilities";
    property url wms2wkServiceUrl: "http://floodobservatory.colorado.edu/geoserver/AS_2wk_rs/wms?service=wms&request=getCapabilities";
    property url wmsJanServiceUrl: "http://floodobservatory.colorado.edu/geoserver/DFO_rs_Jan_till_current_AS/wms?service=wms&request=getCapabilities";
    property url wmsRegWServiceUrl: "http://floodobservatory.colorado.edu/geoserver/Permanent_water_2013-2016-as/wms?service=wms&request=getCapabilities";
    property url wmsHistWServiceUrl: "http://floodobservatory.colorado.edu/geoserver/MOD_history_AS/wms?service=wms&request=getCapabilities";
    property url wmsEventServiceUrl: "http://floodobservatory.colorado.edu/geoserver/Events_AS/wms?service=wms&request=getCapabilities";
    property url wmsWorldPopServiceUrl: "http://floodobservatory.colorado.edu/geoserver/AS_population/wms?service=wms&request=getCapabilities";
    property url filteredEventServiceUrl: wmsEventServiceUrl;
    property var availableEventYears: ["All","2017","2018","2019","2020","2021","2022","2023","2024","2025"];

    property ListModel legendModel: ListModel {
        id: legendModel

        Component.onCompleted: {
            if (app.isOnline) {
                if (app.settings.value("layer_list", false) && JSON.stringify(app.settings.value("layer_list")).includes(app.viewName)) {
                    var dataModel = JSON.parse(app.settings.value("layer_list"));
                    for (var i = 0; i < dataModel.length; i++) {
                        legendModel.append({"name": dataModel[i].legendName, "symbolUrl": dataModel[i].symbolUrl, "visible": dataModel[i].legendVisible});
                    }
                } else {
                    legendModel.append({"name": "Regular Water Extent", "symbolUrl": "../assets/legend_icons/regW_white.png", "visible": true});
                    legendModel.append({"name": "Current Daily Flooded Area / Clouds", "symbolUrl": "../assets/legend_icons/3day_red.png", visible: true});
                    legendModel.append({"name": "Two Week Flooded Area", "symbolUrl": "../assets/legend_icons/2wk_blue.png", "visible": true});
                    legendModel.append({"name": "January till Current Flooded Area", "symbolUrl": "../assets/legend_icons/jant_cyan.png", visible: false});
                    legendModel.append({"name": "Historical Water Extent", "symbolUrl": "../assets/legend_icons/histW_gray.png", "visible": false})
                }
            } else {
                var offDataModel = JSON.parse(app.settings.value("offline_maps"));
                for (var p in offDataModel) {
                    if (offDataModel[p].name.includes(viewName.replace(" ", ""))) {
                        if (JSON.stringify(offDataModel[p]["layer_list"]).includes("Regular")) {
                            legendModel.append({"name": "Regular Water Extent", "symbolUrl": "../assets/legend_icons/regW_white.png", "visible": true});
                        }
                        if (JSON.stringify(offDataModel[p]["layer_list"]).includes("Current")) {
                            legendModel.append({"name": "Current Daily Flooded Area / Clouds", "symbolUrl": "../assets/legend_icons/3day_red.png", visible: true});
                        }
                        if (JSON.stringify(offDataModel[p]["layer_list"]).includes("Two Week")) {
                            legendModel.append({"name": "Two Week Flooded Area", "symbolUrl": "../assets/legend_icons/2wk_blue.png", "visible": true});
                        }
                        break;
                    }
                }
            }
        }
    }

    property var defaultLayersArr: ["Regular Water Extent", "Current Daily Flooded Area / Clouds", "Two Week Flooded Area", "January till Current Flooded Area", "Historical Water Extent", "All Extreme Events", "Nearest Extreme Event"];

    property WmsService service2wk;
    property WmsLayer wmsLayer2wk;

    property WmsService service3day;
    property WmsLayer wmsLayer3day;

    property WmsService serviceJan;
    property WmsLayer wmsLayerJan;

    property WmsService serviceRegW;
    property WmsLayer wmsLayerRegW;

    property WmsService serviceHistW;
    property WmsLayer wmsLayerHistW;

    property WmsService serviceEv
    property list<WmsLayerInfo> layerNAEv;
    property WmsLayer wmsLayerEv;

    property WmsService servicePop;

    property WmsService serviceCu
    property WmsLayerInfo layerCu;
    property WmsLayer wmsLayerCu;
    property var layerCuSL;

    property string descriptionLyr;
    property string compLyrName;

    property double radiusSearch;
    property string radiusSearchUnits;
    property bool drawPin: false;
    property Point pinLocation;
    property SimpleMarkerSceneSymbol symbolMarker;

    header: Controls.Header {
        id: header
    }

    Controls.SceneView {
        id: sceneView
    }

    Controls.MenuDrawer {
        id: menu
    }

    Controls.FloatActionButton {
        id: switchBtn
    }

    Controls.NorthUpBtn {
        id: northUpBtn
    }

    Controls.CurrentPositionBtn {
        id: locationBtn
    }

    Controls.HomePositionBtn {
        id: homeLocationBtn
    }

    Controls.SaveStateBtn {
        id: saveStateBtn
    }

    Controls.OfflineBtn {
        id: offlineBtn
    }

    Controls.SaveStatePage {
        id: saveStagePg
        visible: false
    }

    Controls.OfflinePage {
        id: offlinePg
        visible: app.isOnline ? false : true
    }

    Controls.ClearAllSaveSettings {
        id: clearAllSS
        visible: false
    }

    Controls.DescriptionLayer {
        id: descLyrPage
        visible: false
    }

    Controls.PopScaleMessage {
        id: popScaleM
        visible: false
    }
}
