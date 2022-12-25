using Toybox.WatchUi;
using ContProperties;
using ApiCommunications;

class GarminSmartLockApiBehaviorDelegate extends WatchUi.BehaviorDelegate {

    var garminSmartLockApiView;

    var settings = {};
    var strings = {};

    function initialize() {
        BehaviorDelegate.initialize();

        settings["dataUpdateTimeSecMainProp"] = ContProperties.getProperty(ContProperties.dataUpdateTimeSecMainProp);
        settings["dataUpdateTimeMovingSecMainProp"] = ContProperties.getProperty(ContProperties.dataUpdateTimeMovingSecMainProp);
        settings["movingTimeoutSecProp"] = ContProperties.getProperty(ContProperties.movingTimeoutSecProp);

        switch ( ContProperties.getProperty(ContProperties.useApiModeProp) ) {
            case 0: // SESAMI API
                settings["moveModeProp"] = 0; // toggleモード
                break;

            default: // カスタムAPI
                settings["moveModeProp"] = ContProperties.getProperty(ContProperties.moveModeProp);
                break;
        }

        strings["Moving"] = loadResource(Rez.Strings.Moving);
    }

    function onSelect() {
        // START:STOP押下時、画面タップ時
        if(garminSmartLockApiView.NO_WAIT_STATUS == garminSmartLockApiView.waitStatus){

            garminSmartLockApiView.settingUpdateTime = settings["dataUpdateTimeMovingSecMainProp"];
            if(garminSmartLockApiView.dataUpdateCount > garminSmartLockApiView.settingUpdateTime){
                garminSmartLockApiView.dataUpdateCount = ((garminSmartLockApiView.settingUpdateTime + 1) * garminSmartLockApiView.UPDATE_PER_SEC) - 1;
            }

            garminSmartLockApiView.movingTimeoutCount = ((settings["movingTimeoutSecProp"] + 1) * garminSmartLockApiView.UPDATE_PER_SEC) - 1;

            switch ( garminSmartLockApiView.keyStatus ) {
                case ApiCommunications.LOCKED:
                    garminSmartLockApiView.setIcon(ApiCommunications.MOVING);
                    garminSmartLockApiView.keyStatusText = strings["Moving"];
                    garminSmartLockApiView.waitStatus = ApiCommunications.UNLOCKED;
                    ApiCommunications.moveKey(ApiCommunications.UNLOCK, method(:moveKeyResponseCallback));
                    break;

                case ApiCommunications.UNLOCKED:
                    garminSmartLockApiView.setIcon(ApiCommunications.MOVING);
                    garminSmartLockApiView.keyStatusText = strings["Moving"];
                    garminSmartLockApiView.waitStatus = ApiCommunications.LOCKED;
                    ApiCommunications.moveKey(ApiCommunications.LOCK, method(:moveKeyResponseCallback));
                    break;

                case ApiCommunications.UNKNOWN:
                    garminSmartLockApiView.setIcon(ApiCommunications.MOVING);
                    garminSmartLockApiView.keyStatusText = strings["Moving"];
                    // toggle動作の場合
                    if(0 == settings["moveModeProp"]){
                        garminSmartLockApiView.waitStatus = garminSmartLockApiView.WAIT_LOCK_OR_UNLOCK_STATUS;
                    }else{ // lock/unlock動作の場合
                        garminSmartLockApiView.waitStatus = ApiCommunications.LOCKED;
                    }
                    ApiCommunications.moveKey(ApiCommunications.LOCK, method(:moveKeyResponseCallback));
                    break;
            }
        }

        return true;
    }

    function moveKeyResponseCallback(result) {
        garminSmartLockApiView.apiErrorText = result["errorId"];
    }

    /* 実装なし
    function onPreviousPage() {
        // UP:MENU押下+離した時
        return true;
    }
    function onNextPage() {
        // DOWN押下+離した時
        return true;
    }
    */
}