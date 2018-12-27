-- Create library
CREATE OR REPLACE LIBRARY pyaes 
LANGUAGE plpythonu 
FROM 'https://github.com/ksiddiqui79/redshift_udfs/blob/master/encrypt_decrypt_udf/pyaes.zip?raw=true' 
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
select aes_encrypt('Kawish Siddiqui', 'abcdefghijklnosp') enc_data, aes_decrypt(enc_data, 'abcdefghijklnosp');

-- Test function with same key for encrypt and decrypt
select aes_encrypt('Kawish Siddiqui', 'abcdefghijklnosp') enc_data, aes_decrypt(enc_data, 'abcdefghijklnosp1');
-- Above SQL should throw an error 

-- Check for error details if error occured.
select * from svl_udf_log