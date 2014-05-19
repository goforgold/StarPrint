/**
 * @constructor
 */
var StarPrint = function(){};

PrintPlugin.prototype.print = function(msg, successCallback, errorCallback) {
	
	cordova.exec(successCallback, errorCallback, 'StarPrint', 'print', [msg]);
	
};

PrintPlugin.prototype.isPrintingAvailable = function(successCallback, errorCallback){
	cordova.exec(successCallback, errorCallback, 'StarPrint', 'isPrintingAvailable', []);
};

// Plug in to Cordova
//cordova.addConstructor(function() {
//
//    if (!window.Cordova) {
//        window.Cordova = cordova;
//    };
//
//
//    if(!window.plugins) window.plugins = {};
//    window.plugins.StarPrint = new StarPrint();
//});

if(!window.plugins) window.plugins = {};
    window.StarPrint = new StarPrint();