using Toybox.Lang;
using Toybox.Communications;
using Toybox.StringUtil;
using Toybox.Time;
using Toybox.Cryptography;
using ContProperties;
using ApiCommunications;
using CustomStringUtil;


(:glance)
module SesamiApiCommunications {
    const SESAMI_API_BASE_URL = "https://app.candyhouse.co/api/sesame2/";
    const SESAMI_API_MOVE_ENDPOINT = "/cmd";

    var settings = {};

    function initialize() {
        ApiCommunications.dataParseCallbacks = new SesamiApiDataParseCallbacks();
        
        var sesamiApiData = readSesamiQRCode(ContProperties.getProperty(ContProperties.sesamiQRCode));
        var sesamiHistoryName = ContProperties.getProperty(ContProperties.sesamiHistoryName);
        var sesamiApiKey = ContProperties.getProperty(ContProperties.sesamiApiKey);
        settings["sesamiSecKey"] = hexStringToByteArray(sesamiApiData["secKey"]);

        settings["callApi"] = {
            "getStatus" => {
                "uri" => SESAMI_API_BASE_URL + sesamiApiData["uuid"],
                "method" => Communications.HTTP_REQUEST_METHOD_GET,
                "params" => null,
                "headers" => {
                    "x-api-key" => sesamiApiKey
                }
            },
            "move" => {
                "uri" => SESAMI_API_BASE_URL + sesamiApiData["uuid"] + SESAMI_API_MOVE_ENDPOINT,
                "method" => Communications.HTTP_REQUEST_METHOD_POST,
                "params" => {
                    "cmd" => 88, // toggle
                    "history" => StringUtil.encodeBase64(sesamiHistoryName),
                    "sign" => null // 送信時に設定
                },
                "headers" => {
                    "Content-Type" => "application/json",
                    "x-api-key" => sesamiApiKey
                }
            }
        };
    }

    // 現在状態取得
    function getKeyCurrentStatus(checkCallback) {
        var taskStatus = ApiCommunications.dataParseCallbacks.taskStatus;
        var checkTaskStatus = taskStatus["check"];
        checkTaskStatus["innerCallback"] = checkCallback;

        taskStatus["count"] += 1;

        var callApiForGetStatus = settings["callApi"]["getStatus"];

        // (0:Locked, 1:Unlocked, 2:Moving)
        ApiCommunications.makeRequest(callApiForGetStatus["uri"],
                                      callApiForGetStatus["method"],
                                      callApiForGetStatus["params"],
                                      callApiForGetStatus["headers"],
                                      ApiCommunications.dataParseCallbacks.makeCallback(ApiCommunications.CHECK_API));

        return true;
    }
    
    // 鍵の動作
    function moveKey(moveCallback) {
        var taskStatus = ApiCommunications.dataParseCallbacks.taskStatus;
        var moveTaskStatus = taskStatus["move"];
        moveTaskStatus["innerCallback"] = moveCallback;

        taskStatus["count"] += 1;

        var callApiForMove = settings["callApi"]["move"];

        callApiForMove["params"]["sign"] = createSesamiApiSign();

        ApiCommunications.makeRequest(callApiForMove["uri"],
                                      callApiForMove["method"],
                                      callApiForMove["params"],
                                      callApiForMove["headers"],
                                      ApiCommunications.dataParseCallbacks.makeCallback(ApiCommunications.TOGGLE_API));

        return true;
    }

    // 汎用処理---------------------------------------------

    // セサミのQRコードからUUIDとセキュリティキーを読み出す
    function readSesamiQRCode(sesamiQRCode) {
        var skData = CustomStringUtil.searchSubstring(sesamiQRCode, "sk=", "&l=");
        var decodeSkString = CustomStringUtil.decodeURL(skData);
        var uuid = readSkData(decodeSkString, 83, 86) + "-" + 
                   readSkData(decodeSkString, 87, 88) + "-" + 
                   readSkData(decodeSkString, 89, 90) + "-" + 
                   readSkData(decodeSkString, 91, 92) + "-" + 
                   readSkData(decodeSkString, 93, 98);
        var secKey = readSkData(decodeSkString, 1, 16);
        return {
            "uuid" => uuid,
            "secKey" => secKey
        };
    }

    // skの値からデータを取得する
    function readSkData(data, start, end) {
        var convertSkData = StringUtil.convertEncodedString(data, {
            :fromRepresentation => StringUtil.REPRESENTATION_STRING_BASE64,
            :toRepresentation  => StringUtil.REPRESENTATION_BYTE_ARRAY,
        }).slice(start, end + 1);

        var returnData = "";
        var size = convertSkData.size();
        for(var index = 0; index < size; index++){
            var setData = convertSkData[index] + 256;
            returnData += setData.format("%X").substring(-2, null);
        }

        return returnData;
    }

    // 鍵の動作用にsign値を生成する
    function createSesamiApiSign() {
        var secKey = settings["sesamiSecKey"];
        var message = createMessage();
        
        var sign = aesCmac(secKey, message);

        return sign;
    }

    // Messageの演算
    function createMessage() {
        var date = Time.now().value().toNumber();

        var message = new [4]b;
        message.encodeNumber(date, Lang.NUMBER_FORMAT_UINT32, {});
        return message.slice(1, 4);
    }

    // aesCmacの演算
    function aesCmac(key, message) {
        var cmac = new Cryptography.CipherBasedMessageAuthenticationCode({:algorithm => Cryptography.CIPHER_AES128, :key => key});
        cmac.update(message);
        var digest = cmac.digest();
        return byteArrayToHexString(digest);
    }

    // 16進の文字列をByteArrayに変換
    function hexStringToByteArray(hexString) {
        var hexArray = hexString.toCharArray();
        var hexSize = hexArray.size();

        var convertedByteArray = new [0]b;
        for(var index = 0; index < hexSize; index += 2){
            var addNum = (hexArray[index] + hexArray[index + 1]).toNumberWithBase(16);
            convertedByteArray.add(addNum);
        }
        return convertedByteArray;
    }

    // ByteArrayを16進の文字列に変換
    function byteArrayToHexString(byteArray) {
        var hexSize = byteArray.size();

        var returnData = "";
        for(var index = 0; index < hexSize; index++){
            returnData += byteArray[index].format("%02x");
        }
        return returnData;
    }

    // 16進の文字列をAesCmac用のByteArrayに変換
    function parseAesCmacData(hexString) {
        var hexArray = hexString.toCharArray();
        var hexSize = hexArray.size();

        var convertedByteArray = new [0]b;
        var addString = "";
        for(var index = 0; index < hexSize; index ++){
            addString += hexArray[index];
            if(0 == (index + 1) % 8){
                var addNum = addString.toNumberWithBase(16);
                convertedByteArray.add(addNum);
                addString = "";
            }
        }
        return convertedByteArray;
    }
}