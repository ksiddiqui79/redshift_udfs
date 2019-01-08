# Encryption &amp; Decryption UDF in Amazon Redshift
## Amazon Redshift UDF Support
Amazon Redshift supports [User Defined Fuction](https://docs.aws.amazon.com/redshift/latest/dg/user-defined-functions.html) using SQL or Python.

## Encryption and Decryption UDF
This function uses `pyaes` module to encrypt data using AES `encrypt` and `decrypt` functions.
**AED encryption needs atleast 16 character key to encrypt data, key length less than 16 characters may throw error.**


# Deployment 
## Create library
```SQL
CREATE OR REPLACE LIBRARY pyaes 
LANGUAGE plpythonu 
FROM 'https://github.com/ksiddiqui79/redshift_udfs/blob/master/encrypt_decrypt_udf/using_pyaes/pyaes.zip?raw=true' 
;
```

## Create encrypt function
```SQL
CREATE OR REPLACE FUNCTION aes_encrypt(input VARCHAR(max), vKey VARCHAR(256)) 
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
$$ LANGUAGE plpythonu
;
```

## Create decrypt function
```SQL
CREATE OR REPLACE FUNCTION aes_decrypt(encrypted_msg varchar(max), vKey VARCHAR(256))
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


## Test function with same key for encrypt but different key to decrypt

```SQL
SELECT aes_encrypt(myVal, myKey) enc_data, aes_decrypt(enc_data, myKey||'x')
FROM (SELECT 'Kawish Siddiqui' myVal, LPAD(myVal, 16, 'z') myKey) a;
```

 **Above SQL should throw an error similar to :**
 

```
[Amazon](500310) Invalid operation: ValueError: Invalid key size. Please look at svl_udf_log for more information
Details: 
 -----------------------------------------------;
  error:  ValueError: Invalid key size. Please look at svl_udf_log for more information
  code:      10000
  context:   UDF
  query:     0
  location:  udf_client.cpp:369
  process:   padbmaster [pid=91425]
  -----------------------------------------------;
1 statement failed.
```

### Check for error details if error occured

```SQL
SELECT * FROM svl_udf_log;
```
