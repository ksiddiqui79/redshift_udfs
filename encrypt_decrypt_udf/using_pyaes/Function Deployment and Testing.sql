-- Create library
CREATE OR REPLACE LIBRARY pyaes 
LANGUAGE plpythonu 
FROM 'https://github.com/ksiddiqui79/redshift_udfs/blob/master/encrypt_decrypt_udf/using_pyaes/pyaes.zip?raw=true' 
;


-- Create encrypt function
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

-- Create decrypt function
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

-- Test function with same key for encrypt and decrypt
SELECT aes_encrypt(myVal, myKey) enc_data, aes_decrypt(enc_data, myKey)
FROM (SELECT 'Kawish Siddiqui' myVal, LPAD(myVal, 16, 'z') myKey) a;

-- Test function with same key for encrypt and decrypt
SELECT aes_encrypt(myVal, myKey) enc_data, aes_decrypt(enc_data, myKey||'x')
FROM (SELECT 'Kawish Siddiqui' myVal, LPAD(myVal, 16, 'z') myKey) a;
-- Above SQL should throw an error 

-- Check for error details if error occured.
SELECT * FROM svl_udf_log;