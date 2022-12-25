using Toybox.Graphics;
using Toybox.WatchUi;
using Toybox.Timer;
using ContProperties;
using ApiCommunications;

(:glance)
class GarminSmartLockApiViewGlanceView extends WatchUi.GlanceView {

    var settings = {};
    var strings = {};
    var updateTimer = new Timer.Timer();

    const UPDATE_TIME = 250; // ms
    const UPDATE_PER_SEC = (1000 / UPDATE_TIME);
    
    var dataUpdateCount = 1;
    var keyStatusText = "-";
    var keyStatusColor = Graphics.COLOR_LT_GRAY;

    var apiErrorText = null;

    function initialize() {
        GlanceView.initialize();

        settings["dataUpdateTimeSecGlanceProp"] = ContProperties.getProperty(ContProperties.dataUpdateTimeSecGlanceProp);

        strings["NextUpdate"] = loadResource(Rez.Strings.NextUpdate);
        strings["Error"] = loadResource(Rez.Strings.Error);

        strings["LockedGlance"] = loadResource(Rez.Strings.LockedGlance);
        strings["UnlockedGlance"] = loadResource(Rez.Strings.UnlockedGlance);
        strings["MovingGlance"] = loadResource(Rez.Strings.MovingGlance);
    }

    function onShow() as Void {
        timerCallback(); // 初回実行
        updateTimer.start(method(:timerCallback), UPDATE_TIME, true);
    }

    function onHide() as Void {
        updateTimer.stop();
    }

    function onUpdate(dc as Dc) as Void {
        // レイアウトのクリア
        dc.clear();

        // レイアウトの描画
        var MediumFontHeight = dc.getFontHeight(Graphics.FONT_MEDIUM);
        var displayHeightCenter = dc.getHeight() / 2;
        var displayHeightTextCenter = displayHeightCenter - (MediumFontHeight / 2);

        var drawUpdateCount = dataUpdateCount / UPDATE_PER_SEC;
        if(drawUpdateCount > 99){
            drawUpdateCount = "99+";
        }

        // ステータスの円
        dc.setColor(keyStatusColor, Graphics.COLOR_TRANSPARENT);
        dc.fillCircle(8, displayHeightCenter + 5, 8);

        // 更新までの時間
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
		dc.drawText(24, 2, Graphics.FONT_XTINY, strings["NextUpdate"] + drawUpdateCount, Graphics.TEXT_JUSTIFY_LEFT);

        // ステータス
		dc.drawText(20, displayHeightTextCenter + 4, Graphics.FONT_MEDIUM, keyStatusText, Graphics.TEXT_JUSTIFY_LEFT);

        // アンテナ
        var taskCount = ApiCommunications.dataParseCallbacks.taskStatus["count"];
        if(taskCount < 1){
		    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        }
		dc.fillCircle(3, 18, 2);
		dc.drawArc(0, 20, 9, Graphics.ARC_CLOCKWISE, 83, 3);
		dc.drawArc(0, 20, 12, Graphics.ARC_CLOCKWISE, 83, 0);
        if(taskCount >= 1){
		    dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        }
		dc.drawText(9, 8, Graphics.FONT_XTINY, taskCount, Graphics.TEXT_JUSTIFY_LEFT);

        // エラー
        if(apiErrorText != null){
		    dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(40, displayHeightTextCenter + 12, Graphics.FONT_XTINY, strings["Error"] + apiErrorText, Graphics.TEXT_JUSTIFY_LEFT);
        }
    }

    function timerCallback() {
        dataUpdateCount -= 1;

        // カウンタ満了
        if(dataUpdateCount == 0){
            ApiCommunications.getKeyCurrentStatus(method(:getKeyCurrentStatusResponseCallback));

            if(settings["dataUpdateTimeSecGlanceProp"] < 1){
                dataUpdateCount = 1;
            }else{
                dataUpdateCount = ((settings["dataUpdateTimeSecGlanceProp"] + 1) * UPDATE_PER_SEC) - 1;
            }
        }

        requestUpdate();
    }

    function getKeyCurrentStatusResponseCallback(result) {
        switch ( result["keyCurrentStatus"] ) {
            case ApiCommunications.LOCKED: // LOCKED
                keyStatusText = strings["LockedGlance"];
                keyStatusColor = Graphics.COLOR_RED;
                break;

            case ApiCommunications.UNLOCKED: // UNLOCKED
                keyStatusText = strings["UnlockedGlance"];
                keyStatusColor = Graphics.COLOR_GREEN;
                break;

            case ApiCommunications.MOVING: // MOVING
                keyStatusText = strings["MovingGlance"];
                keyStatusColor = Graphics.COLOR_YELLOW;
                break;

            case ApiCommunications.UNKNOWN: // 不明
                break;
        }

        apiErrorText = result["errorId"];
    }

}
