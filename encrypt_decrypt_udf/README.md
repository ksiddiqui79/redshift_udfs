# Data Encryption in Redshift Using UDF
## Redshift UDF Support
Amazon Redshift supports User Defined scaler Fuction using SQL or Python.

## Encryption and Decryption UDF
This function uses `pyaes` module to encrypt data using AES `encrypt` and `decrypt` functions.
**AED encryption needs atleast 16 character key to encrypt data, key length less than 16 characters may throw error.**


# Deployment 
## Create library
```SQL
CREATE OR REPLACE LIBRARY pyaes 
LANGUAGE plpythonu 
FROM 'https://github.com/ksiddiqui79/redshift_udfs/blob/master/encrypt_decrypt_udf/pyaes.zip?raw=true' 
;
```

## Create encrypt function
```SQL
CREATE OR REPLACE FUNCTION aes_encrypt(input VARCHAR(max), vKey VARCHAR(max)) 
RETURNS VARCHAR STABLE AS $$
  import pyaes 
  import binascii
  if input is None:
    return None  
  key = vKey # Your Key here
  aes=pyaes.AESModeOfOperationCTR(key)
  cipher_txt=aes.encrypt(input)
  cipher_txt2=binascii.hexlify(cipher_txt)

  return str(cipher_txt2.decode('utf-8'))

$$ LANGUAGE plpythonu ;
```

## Create decrypt function
```SQL
CREATE OR REPLACE FUNCTION aes_decrypt(encrypted_msg varchar(max), vKey VARCHAR(max))
RETURNS VARCHAR STABLE AS $$
  import pyaes
  import binascii
  if encrypted_msg is None or len(str(encrypted_msg)) == 0:
       return None
  key = vKey # Your decryption key here
  aes = pyaes.AESModeOfOperationCTR(key)
  encrypted_msg2=binascii.unhexlify(encrypted_msg)
  decrypted_msg2 = aes.decrypt(encrypted_msg2)
  return str(decrypted_msg2.decode('utf-8'))
$$ LANGUAGE plpythonu ;
```
## Test function with same key for encrypt and decrypt
**SQL**
```SQL
SELECT aes_encrypt(myVal, myKey) enc_data, aes_decrypt(enc_data, myKey)
FROM (SELECT 'Kawish Siddiqui' myVal, LPAD(myVal, 16, 'z') myKey) a;
```
**Result**

enc_data | aes_decrypt
-------- | ------------
9a861c3fc1007a9b50f16ef7e1927d | Kawish Siddiqui


## Test function with same key for encrypt and decrypt
```SQL
SELECT aes_encrypt(myVal, myKey) enc_data, aes_decrypt(enc_data, myKey||'x')
FROM (SELECT 'Kawish Siddiqui' myVal, LPAD(myVal, 16, 'z') myKey) a;
```
 **Above SQL should throw an error**

### Check for error details if error occured
```SQL
SELECT * FROM svl_udf_log;
```