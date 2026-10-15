CLASS zcl_alloc_service_policy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS level_of
      IMPORTING
        iv_abc_class    TYPE string
      RETURNING
        VALUE(rv_level) TYPE i.

    METHODS is_strict
      IMPORTING
        iv_abc_class TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS target_of
      IMPORTING
        iv_abc_class     TYPE string
      RETURNING
        VALUE(rv_policy) TYPE string.

ENDCLASS.


CLASS zcl_alloc_service_policy IMPLEMENTATION.

  METHOD level_of.
    " The ABC class sets how much service the material deserves.
    CASE iv_abc_class.
      WHEN 'A'.
        rv_level = 98.
      WHEN 'B'.
        rv_level = 95.
      WHEN OTHERS.
        rv_level = 90.
    ENDCASE.
  ENDMETHOD.

  METHOD is_strict.
    " The top two classes carry the strictest policy.
    rv_ok = xsdbool( iv_abc_class = 'A' OR iv_abc_class = 'B' ).
  ENDMETHOD.

  METHOD target_of.
    " The policy name follows the class.
    CASE iv_abc_class.
      WHEN 'A'.
        rv_policy = 'STRICT'.
      WHEN 'C'.
        rv_policy = 'RELAXED'.
      WHEN OTHERS.
        rv_policy = 'STANDARD'.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
