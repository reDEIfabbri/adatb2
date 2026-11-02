CREATE OR REPLACE TYPE ty_vacc_type AS OBJECT
(
  vacc_type_id VARCHAR2(40),
  vacc_name    VARCHAR2(200),

  CONSTRUCTOR FUNCTION ty_vacc_type RETURN SELF AS RESULT,
  CONSTRUCTOR FUNCTION ty_vacc_type(p_vacc_type_id VARCHAR2)
    RETURN SELF AS RESULT
)
/
CREATE OR REPLACE TYPE BODY ty_vacc_type IS

  CONSTRUCTOR FUNCTION ty_vacc_type RETURN SELF AS RESULT IS
  BEGIN
    RETURN;
  END;

  CONSTRUCTOR FUNCTION ty_vacc_type(p_vacc_type_id VARCHAR2)
    RETURN SELF AS RESULT IS
  BEGIN
    self.vacc_type_id := p_vacc_type_id;
    self.vacc_name    := 'ismeretlen';
  
    RETURN;
  END;

END;
/
