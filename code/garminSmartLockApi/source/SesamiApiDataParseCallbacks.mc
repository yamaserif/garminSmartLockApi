using ApiCommunications;

(:glance)
class SesamiApiDataParseCallbacks {
    const STATUS_KEY = "CHSesame2Status";

    const STATUS_LOCKED_VALUE = "locked";
    const STATUS_UNLOCKED_VALUE = "unlocked";
    const STATUS_MOVING_VALUE = "moved";

    var settings = {};
    var taskStatus = {};

    function initialize() {
        taskStatus["count"] = 0;

        taskStatus["check"] = {
            "innerCallback" => null
        };

        taskStatus["move"] = {
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
                callback = method(:getError);
                break;

            default:
                callback = null;
                break;
        }
        return callback;
    }

    function getKeyCurrentStatusOnReceive(responseCode, data) {
        var checkTaskStatus = taskStatus["check"];
        var checkSettings = settings["check"];

        taskStatus["count"] -= 1;

        if (responseCode == 200) {
            var status = data[STATUS_KEY];

            switch ( status ) {
                case STATUS_LOCKED_VALUE:
                    checkTaskStatus["innerCallback"].invoke({
                        "keyCurrentStatus" => ApiCommunications.LOCKED
                    }); // LOCKED
                    break;

                case STATUS_UNLOCKED_VALUE:
                    checkTaskStatus["innerCallback"].invoke({
                        "keyCurrentStatus" => ApiCommunications.UNLOCKED
                    }); // UNLOCKED
                    break;

                case STATUS_MOVING_VALUE:
                    checkTaskStatus["innerCallback"].invoke({
                        "keyCurrentStatus" => ApiCommunications.MOVING
                    }); // MOVING
                    break;

                default:
                    checkTaskStatus["innerCallback"].invoke({
                        "keyCurrentStatus" => ApiCommunications.UNKNOWN,
                        "errorId" => responseCode
                    }); // 不明
                    break;
            }
        }else{
            checkTaskStatus["innerCallback"].invoke({
                "keyCurrentStatus" => ApiCommunications.UNKNOWN,
                "errorId" => responseCode
            }); // 不明
        }
    }

    function getError(responseCode, data) {
        var moveApiTaskStatus = taskStatus["move"];
        taskStatus["count"] -= 1;

        if (responseCode == 200) {
            moveApiTaskStatus["innerCallback"].invoke({});
        }else{
            moveApiTaskStatus["innerCallback"].invoke({
                "errorId" => responseCode
            });
        }
    }
}