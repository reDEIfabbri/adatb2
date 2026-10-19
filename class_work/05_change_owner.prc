CREATE OR REPLACE PROCEDURE change_owner(p_dog_id       NUMBER
                                        ,p_new_owner_id NUMBER) IS
  l_current_owner_id NUMBER;
BEGIN
  SELECT t.owner_id
    INTO l_current_owner_id
    FROM dog t
   WHERE t.dog_id = p_dog_id;

  UPDATE dog t SET t.owner_id = p_new_owner_id WHERE t.dog_id = p_dog_id;

  INSERT INTO dog_owner_hist
    (dog_id
    ,person_id
    ,tr_time)
  VALUES
    (p_dog_id
    ,l_current_owner_id
    ,SYSDATE);
END;
/
