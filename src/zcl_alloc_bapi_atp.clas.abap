CLASS zcl_alloc_bapi_atp DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             matnr    TYPE matnr,
             werks    TYPE werks_d,
             quantity TYPE menge_d,
             stock    TYPE menge_d,
           END OF ty_input.

    TYPES: BEGIN OF ty_result,
             available TYPE abap_bool,
             confirmed TYPE menge_d,
           END OF ty_result.

    METHODS check
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_result) TYPE ty_result.

ENDCLASS.


CLASS zcl_alloc_bapi_atp IMPLEMENTATION.

  METHOD check.
    IF is_input-quantity > 0 AND is_input-stock >= is_input-quantity.
      rs_result-available = abap_true.
      rs_result-confirmed = is_input-quantity.
      RETURN.
    ENDIF.

    rs_result-available = abap_false.

    IF is_input-stock > 0.
      rs_result-confirmed = is_input-stock.
    ELSE.
      rs_result-confirmed = 0.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
