var token = getQueryString('xtok');
var scenario = 'eu';
var itineraryLanguage = 'EN';
var routingProfile = 'carfast';
var alternativeRoutes = 0;
var routingControl;

// initialize the map f
var map = L.map('map', {
	contextmenu: true,
	contextmenuWidth: 200,
	contextmenuItems: [{
		text: 'Add Waypoint At Start',
		callback: function (ev) {
			if (routingControl._plan._waypoints[0].latLng) {
				routingControl.spliceWaypoints(0, 0, ev.latlng);
			} else {
				routingControl.spliceWaypoints(0, 1, ev.latlng);
			}
		}
	}, {
		text: 'Add Waypoint At End',
		callback: function (ev) {
			if (routingControl._plan._waypoints[routingControl._plan._waypoints.length - 1].latLng) {
				routingControl.spliceWaypoints(routingControl._plan._waypoints.length, 0, ev.latlng);
			} else {
				routingControl.spliceWaypoints(routingControl._plan._waypoints.length - 1, 1, ev.latlng);
			}
		}
	}]
}).setView([50, 10], 4);

// returns a layer group for xmap back- and foreground layers
function getXMapBaseLayers(style, token, labelPane) {
	var attribution = '<a target="_blank" href="http://www.ptvgroup.com">PTV</a>, HERE';

	var background = L.tileLayer('https://api{s}-test.cloud.ptvgroup.com/WMS/GetTile/xmap-' + style + 'bg/{x}/{y}/{z}.png', {
		minZoom: 0,
		maxZoom: 19,
		opacity: 1.0,
		attribution: attribution,
		subdomains: '1234'
	});

	var foreground = L.nonTiledLayer.wms('https://api-test.cloud.ptvgroup.com/WMS/WMS?xtok=' + token, {
		minZoom: 0,
		maxZoom: 19,
		opacity: 1.0,
		layers: 'xmap-' + style + 'fg',
		format: 'image/png',
		transparent: true,
		attribution: attribution,
		pane: 'labels'
	});

	return L.layerGroup([background, foreground]);
}

map.createPane('labels');
map.getPane('labels').style.zIndex = 500;
map.getPane('labels').style.pointerEvents = 'none';

var baseLayers = {
	'PTV classic': getXMapBaseLayers('ajax', token, map._panes.labelPane),
	'PTV gravelpit': getXMapBaseLayers('gravelpit-', token, map._panes.labelPane),
	'PTV silkysand': getXMapBaseLayers('silkysand-', token, map._panes.labelPane).addTo(map),
	'PTV sandbox': getXMapBaseLayers('sandbox-', token, map._panes.labelPane)
};

function setProfile(profile) {
	routingProfile = profile;
}

function setWaypoints(plan)
{
	routingControl.setWaypoints(JSON.parse(plan));
}

L.control.scale().addTo(map);
L.control.layers(baseLayers, [], {
	position: 'bottomleft'
}).addTo(map);

routingControl = L.Routing.control({
	plan: L.Routing.plan(null, {
		createMarker: function (i, wp) {
			return L.marker(wp.latLng, {
				draggable: true,
				icon: L.icon.glyph({
					glyph: String.fromCharCode(65 + i)
				})
			});
		},
		geocoder: L.Control.Geocoder.ptv({
			serviceUrl: 'https://api-test.cloud.ptvgroup.com/xlocate/rs/XLocate/',
			token: token
		}),
		reverseWaypoints: true
	}),
	lineOptions: {
		styles: [
			// Shadow
			{
				color: 'black',
				opacity: 0.8,
				weight: 11
			},
			// Outline
			{
				color: '#888',
				opacity: 0.8,
				weight: 8
			},
			// Center
			{
				color: '#aaa',
				opacity: 1,
				weight: 4
			}
		]
	},
	altLineOptions: {
		styles: [{
				color: 'grey',
				opacity: 0.8,
				weight: 11
			},
			{
				color: '#aaa',
				opacity: 0.8,
				weight: 8
			},
			{
				color: 'white',
				opacity: 1,
				weight: 4
			}
		],
	},
	showAlternatives: true,
	router: L.Routing.ptv({
		serviceUrl: 'https://api-test.cloud.ptvgroup.com/xroute/rs/XRoute/',
		token: token,
		numberOfAlternatives: alternativeRoutes,
		beforeSend: function (request) {
			request.options.push({
				parameter: 'ROUTE_LANGUAGE',
				value: itineraryLanguage
			});

			request.callerContext.properties.push({
				key: 'Profile',
				value: routingProfile
			});

			return request;
		}
	}),
	routeWhileDragging: false,
	routeDragInterval: 500,
	collapsible: true
}).addTo(map);

routingControl.on('routesfound', function(rr) {
	invokeExternal('onRoutesFound', rr.routes[0].summary.totalDistance + '|' + rr.routes[0].summary.totalTime);
});

routingControl.on('routingerror', function (e) {
	console.log(e.message);
});

L.Routing.errorControl(routingControl).addTo(map);

// invoke external method
function invokeExternal(event, param) {
	// add param in 'ExtData' field
	document.body.setAttribute('ExtData', param);
	// triggers StatusTextChange
	window.status = event;			
	// unset immediately afterwards
	window.status = '';
	// return the result from 'ExtData'
	return document.body.getAttribute('ExtData');
} 

/**
 * Get the value of a querystring
 * @param  {String} field The field to get the value of
 * @param  {String} url   The URL to get the value from (optional)
 * @return {String}       The field value
 */
function getQueryString ( field, url ) {
    var href = url ? url : window.location.href;
    var reg = new RegExp( '[?&]' + field + '=([^&#]*)', 'i' );
	var string = reg.exec(href);
    return string ? string[1] : null;
};