CLASS zcl_alloc_return_reason DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS classify
      IMPORTING
        iv_reason       TYPE string
      RETURNING
        VALUE(rv_class) TYPE string.

    METHODS is_reason
      IMPORTING
        iv_reason    TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS code_of
      IMPORTING
        iv_class         TYPE string
      RETURNING
        VALUE(rv_reason) TYPE string.

ENDCLASS.


CLASS zcl_alloc_return_reason IMPLEMENTATION.

  METHOD classify.
    " The reason codes are grouped into the three families a returns desk acts on:
    " a quality defect, a logistics mistake or a customer change of mind.
    IF iv_reason = 'DAMAGED' OR iv_reason = 'DEFECTIVE'
       OR iv_reason = 'QUALITY_ISSUE'.
      rv_class = 'QUALITY'.
    ELSEIF iv_reason = 'WRONG_ITEM' OR iv_reason = 'WRONG_QUANTITY'
           OR iv_reason = 'LATE_DELIVERY'.
      rv_class = 'LOGISTICS'.
    ELSEIF iv_reason = 'CUSTOMER_CHANGE' OR iv_reason = 'NOT_ORDERED'.
      rv_class = 'COMMERCIAL'.
    ENDIF.
  ENDMETHOD.

  METHOD is_reason.
    rv_ok = xsdbool( classify( iv_reason ) IS NOT INITIAL ).
  ENDMETHOD.

  METHOD code_of.
    " The representative code of a family, used when only the family is known.
    CASE iv_class.
      WHEN 'QUALITY'.
        rv_reason = 'DAMAGED'.
      WHEN 'LOGISTICS'.
        rv_reason = 'WRONG_ITEM'.
      WHEN 'COMMERCIAL'.
        rv_reason = 'CUSTOMER_CHANGE'.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
