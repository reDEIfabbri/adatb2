CREATE OR REPLACE PROCEDURE all_dog_details(p_min_weight OUT NUMBER
                                           ,p_max_weight OUT NUMBER
                                           ,p_avg_weight OUT NUMBER) IS
BEGIN
  SELECT MIN(d.birth_weight)
        ,MAX(d.birth_weight)
        ,AVG(d.birth_weight)
    INTO p_min_weight
        ,p_max_weight
        ,p_avg_weight
    FROM dog d;
END all_dog_details;
/
