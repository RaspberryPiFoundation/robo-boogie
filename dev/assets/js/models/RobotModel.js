define(["backbone",
    "jquery",
    "underscore"
  ], function(Backbone, $, _) {
    "use strict";

    /**
    *
    * Model for a Robot
    * 
    * ------------------------------------------------- */
    
    var RobotModel  = Backbone.Model.extend({
        idAttribute: "id",
        defaults: {
            "name": '',
            'sound_id': 1
        }
    });

    return RobotModel;

  
});