CLASS zcl_unit_conversion_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_unit_conversion.
  PRIVATE SECTION.
    TYPES ty_quantity TYPE p LENGTH 8 DECIMALS 3.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_unit_conversion_sap IMPLEMENTATION.
  METHOD zif_unit_conversion~convert.
    DATA lv_input TYPE ty_quantity.
    DATA lv_output TYPE ty_quantity.
    DATA lv_subrc TYPE sy-subrc.

    IF iv_material IS INITIAL
        OR iv_unit_from IS INITIAL
        OR iv_unit_to IS INITIAL
        OR iv_quantity < 0.
      raise_error( iv_message = 'Unit conversion input is invalid' ).
    ENDIF.

    IF iv_unit_from = iv_unit_to.
      rv_quantity = iv_quantity.
      RETURN.
    ENDIF.

    lv_input = iv_quantity.
    CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
      EXPORTING
        i_matnr  = iv_material
        i_in_me  = iv_unit_from
        i_out_me = iv_unit_to
        i_menge  = lv_input
      IMPORTING
        e_menge  = lv_output.
    lv_subrc = sy-subrc.
    IF lv_subrc <> 0.
      raise_error( iv_message = 'Unit conversion failed' ).
    ENDIF.
    IF ( iv_quantity = 0 AND lv_output <> 0 )
        OR lv_output < 0
        OR ( iv_quantity > 0 AND lv_output <= 0 ).
      raise_error( iv_message = 'Unit conversion produced invalid quantity' ).
    ENDIF.
    rv_quantity = lv_output.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
