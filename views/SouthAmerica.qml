import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Controls.Styles 1.4
import QtQuick.Controls.Material 2.1

import ArcGIS.AppFramework 1.0
import ArcGIS.AppFramework.Controls 1.0
import Esri.ArcGISRuntime 100.4

import QtPositioning 5.3

import "../controls" as Controls

Page {
    id: pageItem
    property real scaleFactor: AppFramework.displayScaleFactor
    property url wms2wkServiceUrl: "http://floodobservatory.colorado.edu/geoserver/DFO_2wk_current_SA/wms?service=wms&request=getCapabilities";
    property url wms3dayServiceUrl: "http://floodobservatory.colorado.edu/geoserver/DFO_3day_current_SA/wms?service=wms&request=getCapabilities";
    property url wmsJanServiceUrl: "http://floodobservatory.colorado.edu/geoserver/DFO_Jan_till_current_SA/wms?service=wms&request=getCapabilities";
    property url wmsRegWServiceUrl: "http://floodobservatory.colorado.edu/geoserver/Permanent_water_2013-2016-sa/wms?service=wms&request=getCapabilities";

    property url wmsEventServiceUrl: "http://floodobservatory.colorado.edu/geoserver/Events_NA/wms?service=wms&request=getCapabilities";
    property url wmsGlofasServiceUrl: "http://globalfloods-ows.ecmwf.int/glofas-ows/ows.py?service=wms&request=getCapabilities";

    property WmsService service2wk;
    property WmsLayerInfo layerSA2wk;
    property WmsLayer wmsLayer2wk;

    property WmsService service3day;
    property WmsLayerInfo layerSA3day;
    property WmsLayer wmsLayer3day;

    property WmsService serviceJan;
    property WmsLayerInfo layerSAJan;
    property WmsLayer wmsLayerJan;

    property WmsService serviceRegW;
    property WmsLayerInfo layerSARegW;
    property WmsLayer wmsLayerRegW;

    property WmsService serviceEv
    property WmsLayerInfo layerNAEv;
    property WmsLayer wmsLayerEv;

    property WmsService serviceGlo
    property WmsLayerInfo layerGlo;
    property WmsLayer wmsLayerGlo;
    property var layerGloSL;

    property WmsService serviceCu
    property WmsLayerInfo layerCu;
    property WmsLayer wmsLayerCu;
    property var layerCuSL;

    property Scene scene;
    property string descriptionLyr;

    property bool drawPin: false;
    property Point pinLocation;
    property SimpleMarkerSceneSymbol symbolMarker;

    header: ToolBar {
        id: header
        width: parent.width
        height: 50 * scaleFactor
        Material.background: "#00693e"
        Controls.HeaderBar{}

        ToolButton {
            id: menuButton
            anchors {
                left: parent.left
                verticalCenter: parent.verticalCenter
                leftMargin: 8
            }

            indicator: Image {
                source: "../assets/menu.png"
                anchors.fill: parent
            }

            onClicked: if (sceneView.scene.operationalLayers.count >= 4) {
                           layerList = sceneView.scene.operationalLayers;

                           menu.open();
                       }
        }
    }

    ViewpointCenter {
        id: initView
        center: Point {
            x: -11e6
            y: 6e6
            spatialReference: SpatialReference {wkid: 102100}
        }
        targetScale: 9e7
    }

    // Create SceneView
    SceneView {
        id:sceneView
//        property alias compass: compass

        anchors.fill: parent

        //Busy Indicator
        BusyIndicator {
            anchors.centerIn: parent
            height: 48 * scaleFactor
            width: height
            running: true
            Material.accent:"#00693e"
            visible: (sceneView.drawStatus === Enums.DrawStatusInProgress)
        }

        PositionSource {
            id: positionSource
            active: true
            property bool isInitial: true
            onPositionChanged: {
                if(sceneView.scene !== null && sceneView.scene.loadStatus === Enums.LoadStatusLoaded && isInitial) {
                    isInitial = false;
                    zoomToRegionLocation();

                    function zoomToRegionLocation(){
                        positionSource.update();
                        var currentPositionPoint = ArcGISRuntimeEnvironment.createObject("Point", {x: -62.963135, y: -11.065338, spatialReference: SpatialReference.createWgs84()});
                        var centerPoint = GeometryEngine.project(currentPositionPoint, sceneView.spatialReference);

                        var viewPointCenter = ArcGISRuntimeEnvironment.createObject("ViewpointCenter",{center: centerPoint});
                        sceneView.setViewpoint(viewPointCenter);
                    }
                }
            }
        }

        Component.onCompleted: createWmsLayer();

        function createWmsLayer() {
            var basemap = ArcGISRuntimeEnvironment.createObject("BasemapTopographic");

            // create a scene
            scene = ArcGISRuntimeEnvironment.createObject("Scene", {
                                                              basemap: basemap,
                                                              initialViewpoint: initView,
                                                          });

            // create the services
            service2wk = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wms2wkServiceUrl });
            service3day = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wms3dayServiceUrl });
            serviceJan = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsJanServiceUrl });
            serviceRegW = ArcGISRuntimeEnvironment.createObject("WmsService", { url: wmsRegWServiceUrl });

            // connect to loadStatusChanged signal of the service
            service2wk.loadStatusChanged.connect(function() {
                if (service2wk.loadStatus === Enums.LoadStatusLoaded) {
                    // get the layer info list
                    var service2wkInfo = service2wk.serviceInfo;
                    var layerInfos = service2wkInfo.layerInfos;

                    // get the desired layer from the list
                    layerSA2wk = layerInfos[0].sublayerInfos[0]

                    wmsLayer2wk = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                            layerInfos: [layerSA2wk]
                                                                        });

                    scene.operationalLayers.insert(0, wmsLayer2wk);
                    scene.operationalLayers.setProperty(0, "description", layerSA2wk.description);
                }
            });

            service3day.loadStatusChanged.connect(function() {
                if (service3day.loadStatus === Enums.LoadStatusLoaded) {
                    // get the layer info list
                    var service3dayInfo = service3day.serviceInfo;
                    var layerInfos = service3dayInfo.layerInfos;

                    // get the desired layer from the list
                    layerSA3day = layerInfos[0].sublayerInfos[0]

                    wmsLayer3day = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                             layerInfos: [layerSA3day]
                                                                         });

                    scene.operationalLayers.insert(1, wmsLayer3day);
                    scene.operationalLayers.setProperty(1, "description", layerSA3day.description);

                }
            });

            serviceJan.loadStatusChanged.connect(function() {
                if (serviceJan.loadStatus === Enums.LoadStatusLoaded) {
                    // get the layer info list
                    var serviceJanInfo = serviceJan.serviceInfo;
                    var layerInfos = serviceJanInfo.layerInfos;

                    // get the desired layer from the list
                    layerSAJan = layerInfos[0].sublayerInfos[0]

                    wmsLayerJan = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                            layerInfos: [layerSAJan],
                                                                            visible: false
                                                                        });

                    scene.operationalLayers.insert(2, wmsLayerJan);
                    scene.operationalLayers.setProperty(2, "description", layerSAJan.description);
                }
            });

            serviceRegW.loadStatusChanged.connect(function() {
                if (serviceRegW.loadStatus === Enums.LoadStatusLoaded) {
                    // get the layer info list
                    var serviceRegWInfo = serviceRegW.serviceInfo;
                    var layerInfos = serviceRegWInfo.layerInfos;

                    // get the desired layer from the list
                    layerSARegW = layerInfos[0].sublayerInfos[0]

                    wmsLayerRegW = ArcGISRuntimeEnvironment.createObject("WmsLayer", {
                                                                             layerInfos: [layerSARegW],
                                                                             visible: false
                                                                         });

                    scene.operationalLayers.append(wmsLayerRegW);
                    scene.operationalLayers.setProperty(3, "description", layerSARegW.description);
                }
            });

            // load the services
            service2wk.load();
            service3day.load();
            serviceJan.load();
            serviceRegW.load();


            // set the scene on the sceneview
            sceneView.scene = scene;
        }
    }

    Controls.MenuDrawer {
        id:menu
    }

    Controls.FloatActionButton {
        id:switchBtn
    }

    Controls.CurrentPositionBtn {
        id:locationBtn
    }

    Controls.DescriptionLayer {
        id:descLyrPage
        visible: false
    }
}
