import Toybox.Communications;
import ContProperties;
import SesamiApiCommunications;

(:glance)
module ApiCommunications {

    enum {
        // 状態
        LOCKED = 0,
        UNLOCKED = 1,
        MOVING = 2,
        UNKNOWN = 3,

        // APIの種類
        CHECK_API = 10,
        TOGGLE_API = 11,
        LOCK_API = 12,
        UNLOCK_API = 13,

        // 鍵の動作タイプ
        LOCK = 20,
        UNLOCK = 21
    }

    var settings = {};

    var dataParseCallbacks;

    function initialize() {
        settings["apiMode"] = ContProperties.getProperty(ContProperties.useApiModeProp);
        switch ( settings["apiMode"] ) {
            case 0: // SESAMI API
                SesamiApiCommunications.initialize();
                break;

            default: // カスタムAPI
                customApiInitialize();
                break;
        }
    }

    // 現在状態取得
    function getKeyCurrentStatus(checkApiCallback) {
        switch ( settings["apiMode"] ) {
            case 0: // SESAMI API
                return SesamiApiCommunications.getKeyCurrentStatus(checkApiCallback);

            default: // カスタムAPI
                return customApiGetKeyCurrentStatus(checkApiCallback);
        }
    }

    // 鍵の動作
    function moveKey(moveType, moveApiCallback) {
        switch ( settings["apiMode"] ) {
            case 0: // SESAMI API
                return SesamiApiCommunications.moveKey(moveApiCallback);

            default: // カスタムAPI
                return customApiMoveKey(moveType, moveApiCallback);
        }
    }

    // カスタムAPI---------------------------------------------
    function customApiInitialize() {
        dataParseCallbacks = new DataParseCallbacks();

        settings["checkApi"] = {
            "uri" => ContProperties.getProperty(ContProperties.checkApiUriProp),
            "method" => ContProperties.getProperty(ContProperties.checkApiMethodProp),
            "params" => ContProperties.getProperty(ContProperties.checkApiParamsProp),
            "headers" => ContProperties.getProperty(ContProperties.checkApiHeadersProp)
        };

        // toggle動作の場合
        if(0 == ContProperties.getProperty(ContProperties.moveModeProp)){
            settings["moveApi"] = {
                "lock" => {
                    "uri" => ContProperties.getProperty(ContProperties.toggleApiUriProp),
                    "method" => ContProperties.getProperty(ContProperties.toggleApiMethodProp),
                    "params" => ContProperties.getProperty(ContProperties.toggleApiParamsProp),
                    "headers" => ContProperties.getProperty(ContProperties.toggleApiHeadersProp),
                    "apiType" => TOGGLE_API
                },
                "unlock" => {
                    "uri" => ContProperties.getProperty(ContProperties.toggleApiUriProp),
                    "method" => ContProperties.getProperty(ContProperties.toggleApiMethodProp),
                    "params" => ContProperties.getProperty(ContProperties.toggleApiParamsProp),
                    "headers" => ContProperties.getProperty(ContProperties.toggleApiHeadersProp),
                    "apiType" => TOGGLE_API
                }
            };
        }else{ // lock/unlock動作の場合
            settings["moveApi"] = {
                "lock" => {
                    "uri" => ContProperties.getProperty(ContProperties.lockApiUriProp),
                    "method" => ContProperties.getProperty(ContProperties.lockApiMethodProp),
                    "params" => ContProperties.getProperty(ContProperties.lockApiParamsProp),
                    "headers" => ContProperties.getProperty(ContProperties.lockApiHeadersProp),
                    "apiType" => LOCK_API
                },
                "unlock" => {
                    "uri" => ContProperties.getProperty(ContProperties.unlockApiUriProp),
                    "method" => ContProperties.getProperty(ContProperties.unlockApiMethodProp),
                    "params" => ContProperties.getProperty(ContProperties.unlockApiParamsProp),
                    "headers" => ContProperties.getProperty(ContProperties.unlockApiHeadersProp),
                    "apiType" => UNLOCK_API
                }
            };
        }
    }

    // 現在状態取得
    function customApiGetKeyCurrentStatus(checkApiCallback) {
        var taskStatus = dataParseCallbacks.taskStatus;
        var checkApiTaskStatus = taskStatus["checkApi"];

        taskStatus["count"] += 1;

        var checkApiSettings = settings["checkApi"];
        var methodId = settingMethodIdToCommunicationsMethodId(checkApiSettings["method"]);

        checkApiTaskStatus["innerCallback"] = checkApiCallback;

        // (0:Locked, 1:Unlocked, 2:Moving)
        makeRequest(checkApiSettings["uri"],
                    methodId,
                    checkApiSettings["params"],
                    checkApiSettings["headers"],
                    dataParseCallbacks.makeCallback(CHECK_API));

        return true;
    }
    
    // 鍵の動作
    function customApiMoveKey(moveType, moveApiCallback) {
        var taskStatus = dataParseCallbacks.taskStatus;
        var moveApiTaskStatus = taskStatus["moveApi"];

        taskStatus["count"] += 1;

        var moveApiSettings;
        if(LOCK == moveType){
            moveApiSettings = settings["moveApi"]["lock"];
        }else{
            moveApiSettings = settings["moveApi"]["unlock"];
        }
        var methodId = settingMethodIdToCommunicationsMethodId(moveApiSettings["method"]);

        moveApiTaskStatus["innerCallback"] = moveApiCallback;

        makeRequest(moveApiSettings["uri"],
                    methodId,
                    moveApiSettings["params"],
                    moveApiSettings["headers"],
                    dataParseCallbacks.makeCallback(moveApiSettings["apiType"]));

        return true;
    }

    // 汎用処理---------------------------------------------
    function settingMethodIdToCommunicationsMethodId(settingMethodId) {
        var communicationsMethodId;
        switch ( settingMethodId ) {
            case 0: // GET
                communicationsMethodId = Communications.HTTP_REQUEST_METHOD_GET;
                break;

            case 1: // POST
                communicationsMethodId = Communications.HTTP_REQUEST_METHOD_POST;
                break;

            default:
                communicationsMethodId = Communications.HTTP_REQUEST_METHOD_GET;
                break;
        }
        return communicationsMethodId;
    }

    function makeRequest(uri, method, params, headers, callback) as Void {
        if(headers["Content-Type"] != null){
            if(headers["Content-Type"].equals("application/json")){
                headers["Content-Type"] = Communications.REQUEST_CONTENT_TYPE_JSON;
            }else if(headers["Content-Type"].equals("application/x-www-form-urlencoded")){
                headers["Content-Type"] = Communications.REQUEST_CONTENT_TYPE_URL_ENCODED;
            }
        }
        var options = {
            :method => method,
            :headers => headers
        };
        Communications.makeWebRequest(uri, params, options, callback);
    }
}