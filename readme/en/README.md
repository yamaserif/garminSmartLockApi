# Smart Lock Operation Panel (using Web API)

## SESAMI API (OS 2)
### ★Setting items
- API settings.
    1. API operation mode.
- SESAME API settings.
    1. Terminal name displayed in SESAME history.
    2. String when scanning SESAME's QR code.(Authority is manager or above.)
    3. SESAME API Key.

### API operation mode.
To use the SESAME API function, set the operation mode to "SESAME API".

### Terminal name displayed in SESAME history.
The name that will appear on the SESAME history screen.   
You can set it to any name you wish. (It does not affect the operation itself).

### String when scanning SESAME's QR code.(Authority is manager or above.)
The QR code string generated from the SESAME application.
1. Generate a QR code from Sesame's Share Your Key feature with Manager or higher privileges.
2. Read the generated QR code with any QR code reader. (The string will begin with "ssm://")

### SESAME API Key.
API key for using the SESAME API.  
The API key can be obtained from the following page.  
https://partners.candyhouse.co/login/

---

## Custom API
### ★Setting items
- API settings.
    1. API operation mode.
- Current status acquisition function settings.
    1. WebAPI call URI.(get current status)
    2. WebAPI method.(get current status)
    3. Parameter key of the current status acquisition WebAPI.
    4. Parameter value of the current status acquisition WebAPI.
    5. Header key of the current status acquisition WebAPI.
    6. Header value of the current status acquisition WebAPI.
    7. Key of parameter indicating "locked" in the current status acquisition WebAPI.
    8. Value of parameter indicating "locked" in the current status acquisition WebAPI.
    9. Key of parameter indicating "unlocked" in the Get Current Status WebAPI.
    10. Value of parameter indicating "unlocked" in the current status acquisition WebAPI.
    11. Key of parameter indicating "Moving" in the Get Current Status WebAPI.
    12. Value of parameter indicating "Moving" in the current status acquisition WebAPI.

### ★Setting items when using API for toggle operation specification
(No setting required when using API for locking/unlocking operation specification)
- Key operation settings.
    1. Setting the key operation mode.
    2. WebAPI call URI.(toggle operation)
    3. WebAPI method.(toggle operation)
    4. Parameter key of toggle operation WebAPI.
    5. Parameter value of toggle operation WebAPI.
    6. Header key of toggle operation WebAPI.
    7. Header value of toggle operation WebAPI.

### ★Setting items when using API for locking/unlocking operation specifications
(No setting required when using API with toggle operation specification)
- Key operation settings.
    1. Setting the key operation mode.
    2. WebAPI call URI.(locking operation)
    3. WebAPI method.(locking operation)
    4. Parameter key of locking operation WebAPI.
    5. Parameter value of locking operation WebAPI.
    6. Header key of locking operation WebAPI.
    7. Header value of locking operation WebAPI.
    8. WebAPI call URI.(unlock operation)
    9. WebAPI method.(unlock operation)
    10. Parameter key of unlock operation WebAPI.
    11. Parameter value of unlock operation WebAPI.
    12. Header key of unlock operation WebAPI.
    13. Header value of unlock operation WebAPI.

### API operation mode.
To use the custom API function, set the operation mode to "Custom API".

### WebAPI call URI.
Set the URI to call the WebAPI.

### WebAPI method.
Set the HTTP method for using WebAPI.  
You can choose between GET or POST.

### Parameter key of unlock operation WebAPI, Parameter value of unlock operation WebAPI
Set the parameters to be sent when using WebAPI.  
You can set up to 5 parameters.
```
{
    "Parameter key1": "Parameter value1",
    "Parameter key2": "Parameter value2",
    "Parameter key3": "Parameter value3",
    "Parameter key4": "Parameter value4",
    "Parameter key5": "Parameter value5"
}
```

### Header key of unlock operation WebAPI, Header value of unlock operation WebAPI
Set the headers to be sent when using WebAPI.  
You can set up to 5 parameters.
```
{
    "Header key1": "Header value1",
    "Header key2": "Header value2",
    "Header key3": "Header value3",
    "Header key4": "Header value4",
    "Header key5": "Header value5"
}
```
### Key of parameter indicating "locked" in the current status acquisition WebAPI, Value of parameter indicating "locked" in the current status acquisition WebAPI
You can set the parameter value that indicates locked/unlocked/activated in the returned response.  
If the hierarchy is deep, separate them with "." to separate the responses.
```
Example: response.status
{
    "response": {
        "status": "data"
    }
}
```
