-- Create library
CREATE OR REPLACE LIBRARY pycrypto 
LANGUAGE plpythonu 
FROM 'https://github.com/ksiddiqui79/redshift_udfs/raw/master/encrypt_decrypt_udf/using_pycrypto/pycrypto-2.6.1.zip' 
;


-- Create encrypt function
CREATE OR REPLACE FUNCTION aes_pc_encrypt(input VARCHAR(max), vKey VARCHAR(256)) 
RETURNS VARCHAR STABLE AS $$
  import pycrypto 
  from pycrypto.Crypto.Cipher import AES
  from pycrypto.Crypto import Random
  import hashlib
  import binascii
  #
  if input is None:
    return None
  enc_base=32
  key = hashlib.sha256(vKey.encode()).digest()  # Your Key here
  value2enc=input + (enc_base - len(input) % enc_base) * chr(enc_base - len(input) % enc_base)
  iv = Random.new().read(AES.block_size)
  cipher = AES.new(key, AES.MODE_CBC, iv)
  return base64.b64encode(iv + cipher.encrypt(value2enc))
$$ LANGUAGE plpythonu ;

-- Create decrypt function
CREATE OR REPLACE FUNCTION aes_pc_decrypt(encrypted_msg varchar(max), vKey VARCHAR(256))
RETURNS VARCHAR STABLE AS $$
  import pycrypto
  import binascii
  if encrypted_msg is None or len(str(encrypted_msg)) == 0:
       return None
  key = vKey # Your decryption key here
  aes = pycrypto.AESModeOfOperationCTR(key)
  encrypted_msg2=binascii.unhexlify(encrypted_msg)
  decrypted_msg2 = aes.decrypt(encrypted_msg2)
  return str(decrypted_msg2.decode('utf-8'))
$$ LANGUAGE plpythonu ;

-- Test function with same key for encrypt and decrypt
SELECT aes_pc_encrypt(myVal, myKey) enc_data, aes_pc_decrypt(enc_data, myKey)
FROM (SELECT 'Kawish Siddiqui' myVal, LPAD(myVal, 16, 'z') myKey) a;

-- Test function with same key for encrypt and decrypt
SELECT aes_pc_encrypt(myVal, myKey) enc_data, aes_pc_decrypt(enc_data, myKey||'x')
FROM (SELECT 'Kawish Siddiqui' myVal, LPAD(myVal, 16, 'z') myKey) a;
-- Above SQL should throw an error 

-- Check for error details if error occured.
SELECT * FROM svl_udf_log;