using Toybox.Application.Properties;

(:glance)
module ContProperties {
    var cache = {};

    enum {
        // 表示情報更新に関連する設定項目
        dataUpdateTimeSecGlanceProp = "dataUpdateTimeSecGlanceProp", // ウィジェット一覧画面の更新頻度(秒)
        dataUpdateTimeSecMainProp = "dataUpdateTimeSecMainProp", // アプリ画面の更新頻度(秒)
        dataUpdateTimeMovingSecMainProp = "dataUpdateTimeMovingSecMainProp", // 鍵動作中のアプリ画面の更新頻度(秒)

        // タイムアウトに関連する設定項目
        movingTimeoutSecProp = "movingTimeoutSecProp", // 鍵動作中のタイムアウト時間(秒)

        // 以下API関連----------------------------------------------------------------------------------

        useApiModeProp = "useApiModeProp", // 

        // SESAME APIを使用(Sesame3/4モード)-------------------------------------------------------------
        sesamiHistoryName = "sesamiHistoryName",
        sesamiQRCode = "sesamiQRCode",
        sesamiApiKey = "sesamiApiKey",

        // カスタムAPI-----------------------------------------------------------------------------------
        // 現在状態取得機能に関連する設定項目
        checkApiUriProp = "checkApiUriProp", // WebAPI呼び出しURI(現在状態取得)
        checkApiMethodProp = "checkApiMethodProp", // WebAPIのメソッド(施錠動作)
        checkApiParamsProp = "checkApiParamsProp", // 現在状態取得WebAPIのパラメータ
        checkApiHeadersProp = "checkApiHeadersProp", // 現在状態取得WebAPIのヘッダー

        checkApiParamLockedProp = "checkApiParamLockedProp", // 現在状態取得WebAPIにて「施錠済」を表すパラメータ
        checkApiParamUnlockedProp = "checkApiParamUnlockedProp", // 現在状態取得WebAPIにて「解錠済」を表すパラメータ
        checkApiParamMovingProp = "checkApiParamMovingProp", // 現在状態取得WebAPIにて「作動中」を表すパラメータ

        // 鍵の動作に関連する設定項目
        moveModeProp = "moveModeProp", // 鍵の動作モードを設定する
        toggleApiUriProp = "toggleApiUriProp", // WebAPI呼び出しURI(トグル動作)
        toggleApiMethodProp = "toggleApiMethodProp", // WebAPIのメソッド(トグル動作)
        toggleApiParamsProp = "toggleApiParamsProp", // トグル動作WebAPIのパラメータ
        toggleApiHeadersProp = "toggleApiHeadersProp", // トグル動作WebAPIのヘッダー

        lockApiUriProp = "lockApiUriProp", // WebAPI呼び出しURI(施錠動作)
        lockApiMethodProp = "lockApiMethodProp", // WebAPIのメソッド(施錠動作)
        lockApiParamsProp = "lockApiParamsProp", // 施錠動作WebAPIのパラメータ
        lockApiHeadersProp = "lockApiHeadersProp", // 施錠動作WebAPIのヘッダー

        unlockApiUriProp = "unlockApiUriProp", // WebAPI呼び出しURI(解錠動作)
        unlockApiMethodProp = "unlockApiMethodProp", // WebAPIのメソッド(解錠動作)
        unlockApiParamsProp = "unlockApiParamsProp", // 解錠動作WebAPIのパラメータ
        unlockApiHeadersProp = "unlockApiHeadersProp" // 解錠動作WebAPIのヘッダー
    }

    function getProperty(id) {
        if(cache.hasKey(id)){
            return cache[id];
        }

        var resultData;

        switch ( id ) {
            case checkApiParamLockedProp:
            case checkApiParamUnlockedProp:
            case checkApiParamMovingProp:
                resultData = {
                    "key" => Properties.getValue(id + "Key"),
                    "value"  => Properties.getValue(id + "Value")
                };
                break;

            case checkApiParamsProp:
            case toggleApiParamsProp:
            case lockApiParamsProp:
            case unlockApiParamsProp:
            case checkApiHeadersProp:
            case toggleApiHeadersProp:
            case lockApiHeadersProp:
            case unlockApiHeadersProp:
                var size = 5;
                var props = {} as Dictionary<String, String>;

                for( var i = 0; i < size; i++ ) {
                    var propIndex = i + 1;
                    var key = Properties.getValue(id + "Key" + propIndex);
                    var value = Properties.getValue(id + "Value" + propIndex);
                    if(!key.equals("")){
                        props[key] = value;
                    }
                }
                resultData = props;
                break;

            default:
                resultData = Properties.getValue(id);
                break;
        }
        cache[id] = resultData;
        return resultData;
    }

}
