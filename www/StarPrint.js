/**
 * @constructor
 */
var StarPrint = function(){};

PrintPlugin.prototype.print = function(msg, successCallback, errorCallback, uri, type, title) {
	
	cordova.exec(successCallback, errorCallback, 'PrintPlugin', 'print', [msg]);
	
};

PrintPlugin.prototype.isPrintingAvailable = function(successCallback, errorCallback){
	cordova.exec(successCallback, errorCallback, 'PrintPlugin', 'isPrintingAvailable', []);
};

// Plug in to Cordova
cordova.addConstructor(function() {

    if (!window.Cordova) {
        window.Cordova = cordova;
    };


    if(!window.plugins) window.plugins = {};
    window.plugins.StarPrint = new StarPrint();
});
