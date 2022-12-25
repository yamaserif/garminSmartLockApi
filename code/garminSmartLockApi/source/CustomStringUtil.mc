(:glance)
module CustomStringUtil {
    const ENCODE_URL_TABLE = {
        "%20" => ' ',
        "%21" => '!',
        "%22" => '"',
        "%23" => '#',
        "%24" => '$',
        "%25" => '%',
        "%26" => '&',
        "%27" => '\'',
        "%28" => '(',
        "%29" => ')',
        "%2A" => '*',
        "%2B" => '+',
        "%2C" => ',',
        "%2F" => '/',
        "%3A" => ':',
        "%3B" => ';',
        "%3C" => '<',
        "%3D" => '=',
        "%3E" => '>',
        "%3F" => '?',
        "%40" => '@',
        "%5B" => '[',
        "%5D" => ']',
        "%5E" => '^',
        "%60" => '`',
        "%7B" => '{',
        "%7C" => '|',
        "%7D" => '}',
        "%7E" => '~'
    };

    function searchSubstring(baseString, startString, endString) {
        var startIndex = baseString.find(startString) + startString.length();
        var endIndex = baseString.find(endString);

        return baseString.substring(startIndex, endIndex);
    }

    function decodeURL(baseString) {
        var keys = ENCODE_URL_TABLE.keys();
        var values = ENCODE_URL_TABLE.values();
        var checkSize = ENCODE_URL_TABLE.size();
        for(var index = 0; index < checkSize; index++){
            baseString = replaceAll(baseString, keys[index], values[index]);
        }

        return baseString;
    }

    function replaceAll(baseString, before, after) {
        var beforeLength = before.length();
        while (true){
            var replaceIndex = baseString.find(before);
            if(null != replaceIndex){
                var headString = baseString.substring(null, replaceIndex);
                var tailString = baseString.substring(replaceIndex + beforeLength, null);
                baseString = headString + after + tailString;
            }else{
                break;
            }
        }
        
        return baseString;
    }
}