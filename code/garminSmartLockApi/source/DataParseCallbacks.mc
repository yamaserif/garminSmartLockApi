import Toybox.StringUtil;
import ApiCommunications;

(:glance)
class DataParseCallbacks {
    var settings = {};
    var taskStatus = {};

    function initialize() {
        settings["checkApi"] = {
            "paramLocked" => ContProperties.getProperty(ContProperties.checkApiParamLockedProp),
            "paramUnlocked" => ContProperties.getProperty(ContProperties.checkApiParamUnlockedProp),
            "paramMoving" => ContProperties.getProperty(ContProperties.checkApiParamMovingProp)
        };

        taskStatus["count"] = 0;

        taskStatus["checkApi"] = {
            "innerCallback" => null
        };

        taskStatus["moveApi"] = {
            "innerCallback" => null
        };
    }

    function makeCallback(apiId) {
        var callback;

        switch ( apiId ) {
            case ApiCommunications.CHECK_API:
                callback = method(:getKeyCurrentStatusOnReceive);
                break;

            case ApiCommunications.TOGGLE_API:
            case ApiCommunications.LOCK_API:
            case ApiCommunications.UNLOCK_API:
                callback = method(:getError);
                break;

            default:
                callback = null;
                break;
        }
        return callback;
    }

    function getKeyCurrentStatusOnReceive(responseCode, data) {
        var checkApiTaskStatus = taskStatus["checkApi"];
        var checkApiSettings = settings["checkApi"];

        taskStatus["count"] -= 1;

        if (responseCode == 200) {
            var paramLockedResult = dataPropPickup(data, checkApiSettings["paramLocked"]["key"]);
            if(checkApiSettings["paramLocked"]["value"].equals(paramLockedResult)){
                checkApiTaskStatus["innerCallback"].invoke({
                    "keyCurrentStatus" => ApiCommunications.LOCKED
                }); // LOCKED
                return;
            }
            
            var paramUnlockedResult = dataPropPickup(data, checkApiSettings["paramUnlocked"]["key"]);
            if(checkApiSettings["paramUnlocked"]["value"].equals(paramUnlockedResult)){
                checkApiTaskStatus["innerCallback"].invoke({
                    "keyCurrentStatus" => ApiCommunications.UNLOCKED
                }); // UNLOCKED
                return;
            }
            
            var paramMovingResult = dataPropPickup(data, checkApiSettings["paramMoving"]["key"]);
            if(checkApiSettings["paramMoving"]["value"].equals(paramMovingResult)){
                checkApiTaskStatus["innerCallback"].invoke({
                    "keyCurrentStatus" => ApiCommunications.MOVING
                }); // MOVING
                return;
            }
        }

        checkApiTaskStatus["innerCallback"].invoke({
            "keyCurrentStatus" => ApiCommunications.UNKNOWN,
            "errorId" => responseCode
        }); // 不明
    }

    function getError(responseCode, data) {
        var moveApiTaskStatus = taskStatus["moveApi"];
        taskStatus["count"] -= 1;

        if (responseCode == 200) {
            moveApiTaskStatus["innerCallback"].invoke({});
        }else{
            moveApiTaskStatus["innerCallback"].invoke({
                "errorId" => responseCode
            });
        }
    }

    function dataPropPickup(data, pickKey) {
        var pickKeyArray = pickKey.toCharArray();
        pickKeyArray.add('.');

        do {
            var checkKeyArray = [];
            while( pickKeyArray[0] != '.' ){
                var checkChar = pickKeyArray[0];
                checkKeyArray.add(checkChar);
                pickKeyArray.remove(checkChar);
            }
            pickKeyArray.remove('.');

            var checkKey = StringUtil.charArrayToString(checkKeyArray);
            data = data[checkKey];
        }while( (data != null) && (pickKeyArray.size() > 0) );

        if(data == null){
            data = "";
        }
        return data;
    }
}