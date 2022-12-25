using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Timer;
using ContProperties;
using ApiCommunications;

class GarminSmartLockApiView extends WatchUi.View {
    var settings = {};
    var strings = {};
    var updateTimer = new Timer.Timer();
    var settingUpdateTime;

    const UPDATE_TIME = 250; // ms
    const UPDATE_PER_SEC = (1000 / UPDATE_TIME);
    
    var dataUpdateCount = 1;
    var keyStatusText = "-";
    var keyStatus = ApiCommunications.UNKNOWN;
    var keyStatusColor = Graphics.COLOR_LT_GRAY;

    const NO_WAIT_STATUS = 101;
    const WAIT_LOCK_OR_UNLOCK_STATUS = 102;
    var waitStatus = NO_WAIT_STATUS;
    var movingTimeoutCount = -1;

    var apiErrorText = null;

    function initialize() {
        View.initialize();

        settings["dataUpdateTimeSecMainProp"] = ContProperties.getProperty(ContProperties.dataUpdateTimeSecMainProp);

        settingUpdateTime = settings["dataUpdateTimeSecMainProp"];

        strings["NextUpdate"] = loadResource(Rez.Strings.NextUpdate);
        strings["Error"] = loadResource(Rez.Strings.Error);

        strings["Locked"] = loadResource(Rez.Strings.Locked);
        strings["Unlocked"] = loadResource(Rez.Strings.Unlocked);
        strings["Moving"] = loadResource(Rez.Strings.Moving);
    }

    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    function onShow() as Void {
        timerCallback(); // 初回実行
        updateTimer.start(method(:timerCallback), UPDATE_TIME, true);
    }

    function onHide() as Void {
        updateTimer.stop();
    }

    function onUpdate(dc as Dc) as Void {
        var drawUpdateCount = dataUpdateCount / UPDATE_PER_SEC;
        if(drawUpdateCount > 99){
            drawUpdateCount = "99+";
        }

        // 更新までの時間
        var nextUpdateDrawable = View.findDrawableById("NextUpdate");
        (nextUpdateDrawable as Text).setText(strings["NextUpdate"] + drawUpdateCount);

        // ステータス
        var statusDrawable = View.findDrawableById("Status");
        (statusDrawable as Text).setText(keyStatusText);

        // エラー
        var errorText = "";
        if(apiErrorText != null){
		    // dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            errorText = strings["Error"] + apiErrorText;
        }
        var errorDrawable = View.findDrawableById("Error");
        (errorDrawable as Text).setText(errorText);

        View.onUpdate(dc);
    }

    function timerCallback() {
        dataUpdateCount -= 1;

        if(movingTimeoutCount != -1){
            movingTimeoutCount -= 1;
        }

        // カウンタ満了
        if(dataUpdateCount == 0){
            ApiCommunications.getKeyCurrentStatus(method(:getKeyCurrentStatusResponseCallback));

            if(settingUpdateTime < 1){
                dataUpdateCount = 1;
            }else{
                dataUpdateCount = ((settingUpdateTime + 1) * UPDATE_PER_SEC) - 1;
            }
        }

        if(movingTimeoutCount == 0){
            movingTimeoutCount = -1;

            settingUpdateTime = settings["dataUpdateTimeSecMainProp"];
            if(dataUpdateCount > settingUpdateTime){
                dataUpdateCount = ((settingUpdateTime + 1) * UPDATE_PER_SEC) - 1;
            }

            waitStatus = NO_WAIT_STATUS;
        }

        requestUpdate();
    }

    function getKeyCurrentStatusResponseCallback(result) {
        if((NO_WAIT_STATUS == waitStatus) || (result["keyCurrentStatus"] == waitStatus)){
            
            if((result["keyCurrentStatus"] == waitStatus)){
                settingUpdateTime = settings["dataUpdateTimeSecMainProp"];
                if(dataUpdateCount > settingUpdateTime){
                    dataUpdateCount = ((settingUpdateTime + 1) * UPDATE_PER_SEC) - 1;
                }

                waitStatus = NO_WAIT_STATUS;
            }

            switch ( result["keyCurrentStatus"] ) {
                case ApiCommunications.LOCKED: // LOCKED
                    keyStatusText = strings["Locked"];
                    keyStatusColor = Graphics.COLOR_RED;
                    keyStatus = ApiCommunications.LOCKED;
                    break;

                case ApiCommunications.UNLOCKED: // UNLOCKED
                    keyStatusText = strings["Unlocked"];
                    keyStatusColor = Graphics.COLOR_GREEN;
                    keyStatus = ApiCommunications.UNLOCKED;
                    break;

                case ApiCommunications.MOVING: // MOVING
                    keyStatusText = strings["Moving"];
                    keyStatusColor = Graphics.COLOR_YELLOW;
                    keyStatus = ApiCommunications.MOVING;
                    break;

                case ApiCommunications.UNKNOWN: // 不明
                    keyStatus = ApiCommunications.UNKNOWN;
                    break;
            }

            setIcon(result["keyCurrentStatus"]);
        }else if(WAIT_LOCK_OR_UNLOCK_STATUS == waitStatus){
            switch ( result["keyCurrentStatus"] ) {
                case ApiCommunications.LOCKED: // LOCKED
                    waitStatus = ApiCommunications.UNLOCKED;
                    break;

                case ApiCommunications.UNLOCKED: // UNLOCKED
                    waitStatus = ApiCommunications.LOCKED;
                    break;
            }
        }
        apiErrorText = result["errorId"];
    }

    function setIcon(keyCurrentStatus) {
        var lockedIconDrawable = View.findDrawableById("LockedIcon");
        var unlockedIconDrawable = View.findDrawableById("UnlockedIcon");
        var movingIconDrawable = View.findDrawableById("MovingIcon");
        var unknownIconDrawable = View.findDrawableById("UnknownIcon");

        lockedIconDrawable.isVisible = false;
        unlockedIconDrawable.isVisible = false;
        movingIconDrawable.isVisible = false;
        unknownIconDrawable.isVisible = false;

        switch ( keyCurrentStatus ) {
            case ApiCommunications.LOCKED: // LOCKED
                lockedIconDrawable.isVisible = true;
                break;

            case ApiCommunications.UNLOCKED: // UNLOCKED
                unlockedIconDrawable.isVisible = true;
                break;

            case ApiCommunications.MOVING: // MOVING
                movingIconDrawable.isVisible = true;
                break;

            case ApiCommunications.UNKNOWN: // 不明
                unknownIconDrawable.isVisible = true;
                break;
        }
    }

}
