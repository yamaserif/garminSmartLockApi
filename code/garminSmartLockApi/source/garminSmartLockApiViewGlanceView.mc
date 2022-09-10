import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Timer;

(:glance)
class garminSmartLockApiViewGlanceView extends WatchUi.GlanceView {

    var myCount =  0;

    function initialize() {
        GlanceView.initialize();

        var myTimer = new Timer.Timer();
        myTimer.start(method(:timerCallback), 1000, true);
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
		dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_RED);
		dc.drawText(0, 0, Graphics.FONT_SMALL, loadResource(Rez.Strings.LockedGlance) + myCount, Graphics.TEXT_JUSTIFY_LEFT);
    }

    function timerCallback() {
        myCount += 1;
        requestUpdate();
    }

}
