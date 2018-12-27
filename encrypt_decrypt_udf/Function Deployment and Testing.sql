-- Create library
CREATE OR REPLACE LIBRARY pyaes 
LANGUAGE plpythonu 
FROM 's3://muhamsi-scripts/rs_encryption_udf/pyaes.zip' 
CREDENTIALS 'aws_iam_role=arn:aws:iam::866075764043:role/RedshiftRole';


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

-- Test function

select aes_encrypt('Kawish Siddiqui', 'abcdefghijklnosp') enc_data, aes_decrypt(enc_data, 'abcdefghijklnosp');
