/**
 * @constructor
 */
var StarPrint = function(){};

StarPrint.prototype.print = function(portName, printContent, successCallback, errorCallback) {
	
	cordova.exec(successCallback, errorCallback, 'StarPrint', 'print', [portName, printContent]);
	
};

StarPrint.prototype.isPrintingAvailable = function(successCallback, errorCallback){
	cordova.exec(successCallback, errorCallback, 'StarPrint', 'isPrintingAvailable', []);
};

// Plug in to Cordova
cordova.addConstructor(function() {

    if (!window.Cordova) {
        window.Cordova = cordova;
    };


    //if(!window.plugins) window.plugins = {};
    window.StarPrint = new StarPrint();
});