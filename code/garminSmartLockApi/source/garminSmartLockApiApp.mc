import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Application;
import ApiCommunications;

// ウィジェットなのでglanceの機能を使用する
(:glance)
class GarminSmartLockApiApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
        ApiCommunications.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        var garminSmartLockApiView = new GarminSmartLockApiView();
        var garminSmartLockApiBehaviorDelegate = new GarminSmartLockApiBehaviorDelegate();

        garminSmartLockApiBehaviorDelegate.garminSmartLockApiView = garminSmartLockApiView;

        return [
            garminSmartLockApiView,
            garminSmartLockApiBehaviorDelegate
        ] as Array<Views or InputDelegates>;
    }

    // glanceの表示内容
    function getGlanceView() as Array<GlanceView or GlanceViewDelegate>? {
        var garminSmartLockApiViewGlanceView = new GarminSmartLockApiViewGlanceView();

        return [
            garminSmartLockApiViewGlanceView
        ] as Array<GlanceView or GlanceViewDelegate>;
    }
}

function getApp() as GarminSmartLockApiApp {
    return Application.getApp() as GarminSmartLockApiApp;
}