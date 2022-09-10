import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

// ウィジェットなのでglanceの機能を使用する
(:glance)
class garminSmartLockApiApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new garminSmartLockApiView() ] as Array<Views or InputDelegates>;
    }

    // glanceの表示内容
    function getGlanceView() as Array<GlanceView>? {
        return [ new garminSmartLockApiViewGlanceView() ] as Array<GlanceView or GlanceViewDelegate>;
    }
}

function getApp() as garminSmartLockApiApp {
    return Application.getApp() as garminSmartLockApiApp;
}