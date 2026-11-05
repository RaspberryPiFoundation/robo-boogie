define(["backbone",
    "config/urlConfig",
    "underscore"], function(Backbone, UrlConfig, _) {
    "use strict";

    /**
    *
    * User Model
    * 
    * ------------------------------------------------- */
    
    var UserModel  = Backbone.Model.extend({
        idAttribute: "uuid",
        url: function () {

            var urlConfig   = new UrlConfig();

            if (this.isNew()){

                return urlConfig.get('url') + "/api/users";

            } else {

                return urlConfig.get('url') + "/api/users/" + this.id;

            }

        }
    });

    return UserModel;

  
});