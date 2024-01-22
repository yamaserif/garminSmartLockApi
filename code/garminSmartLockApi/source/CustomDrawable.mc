import Toybox.Lang;
import Toybox.Graphics;
import Toybox.WatchUi;

class TaskCountIcon extends WatchUi.Drawable {

    const X = 0.93; // 93%
    const Y = 0.43; // 43%

    function initialize(params as Dictionary) {
        Drawable.initialize(params);
    }

    function draw(dc as Dc) as Void {
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var displayHeight = dc.getHeight() * Y;
        var displayWidth = dc.getWidth() * X;
        var taskCount = ApiCommunications.dataParseCallbacks.taskStatus["count"];
        if(taskCount < 1){
		    dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        }
		dc.fillCircle(3+displayWidth, 18+displayHeight, 2);
		dc.drawArc(0+displayWidth, 20+displayHeight, 9, Graphics.ARC_CLOCKWISE, 83, 3);
		dc.drawArc(0+displayWidth, 20+displayHeight, 12, Graphics.ARC_CLOCKWISE, 83, 0);
        if(taskCount >= 1){
		    dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
        }
		dc.drawText(9+displayWidth, 8+displayHeight, Graphics.FONT_XTINY, taskCount, Graphics.TEXT_JUSTIFY_LEFT);
    }
}